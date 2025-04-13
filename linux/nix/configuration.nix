{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Basic system configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.plymouth.enable = true;

  # Set hostname
  networking.hostName = "mk";
  networking.networkmanager.enable = true;

  # Set timezone
  time.timeZone = "Europe/Vienna";

  # Localization settings
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "de-latin1";
  };

  hardware.pulseaudio.enable = false;

  # Power management
  services.thermald.enable = true;
  powerManagement.enable = true;

  # Nix configuration
  nix = {
    package = pkgs.nixVersions.stable;
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "mk" ];

      # Configure binary caches
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
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
    cantarell-fonts

    (pkgs.callPackage ./sddm-astronaut.nix {
      themeConfig = {
        # Optional theme configuration
        # Background = "/path/to/background.jpg";
      };
    })
  ];

  # Enable services for some packages
  services = {
    # Pipewire
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    # Display Manager
    displayManager = {
      sddm = {
        enable = true;
        theme = "astronaut";
        wayland.enable = true;
        settings = {
          Theme = {
            Font = "Cantarell 10";
          };
          Users = {
            DefaultUser = "mk";
          };
          Wayland = {
            EnableHiDPI = true;
          };
        };
      };
    };

    # Syncthing
    syncthing = {
      enable = true;
      user = "root";
      dataDir = "/var/lib/syncthing";
      configDir = "/var/lib/syncthing/.config/syncthing";
    };

    # SSH
    openssh.enable = true;
  };

  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  # Podman configuration
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  }

  programs.dconf.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # X11 keyboard layout
  services.xserver.layout = "de";
  services.xserver.xkbVariant = "nodeadkeys";

  hardware.firmware = with pkgs; [
    firmwareLinuxNonfree
  ];
}
