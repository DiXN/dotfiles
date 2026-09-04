{ pkgs, ... }:

{
  imports = [
    ./sops.nix
    ./ai-keys.nix
  ];

  home-manager.users.mk.imports = [
    ../home/shell.nix
    ../home/dots.nix
  ];

  # Basic system configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.plymouth.enable = false;

  networking.networkmanager.enable = true;

  system.stateVersion = "26.05";

  # Set timezone
  time.timeZone = "Europe/Vienna";

  # Localization settings
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "de-latin1";
  };

  # Nix configuration
  nix = {
    package = pkgs.nixVersions.stable;
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      accept-flake-config = true;
      trusted-users = [ "root" "mk" ];

      # Configure binary caches
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://niri.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # User configuration
  users.users.mk = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "input" "autologin" "docker" "networkmanager" ];
    shell = pkgs.zsh;
    initialPassword = "mk";
  };
  security.sudo.wheelNeedsPassword = false;

  environment.sessionVariables = rec {
    XDG_CACHE_HOME  = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME   = "$HOME/.local/share";
    XDG_STATE_HOME  = "$HOME/.local/state";

    # Not officially in the specification
    XDG_BIN_HOME    = "$HOME/.local/bin";

    PATH = [
      "${XDG_BIN_HOME}"
    ];
  };

  # Package management (system-wide packages)
  environment.systemPackages = with pkgs; [
    # Core system utilities
    git
    openssh
    rsync
    nfs-utils
    kexec-tools
    less
    tree
    cachix
    sops
    age
  ];

  # Syncthing
  services.syncthing = {
    enable = true;
    user = "root";
    dataDir = "/var/lib/syncthing";
    configDir = "/var/lib/syncthing/.config/syncthing";
  };

  # SSH
  services.openssh.enable = true;

  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
