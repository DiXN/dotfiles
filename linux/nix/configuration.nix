{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Basic system configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.plymouth.enable = true;

  # Set hostname
  networking.hostName = "mk";

  # Set timezone
  time.timeZone = "Europe/Vienna";

  # Localization settings
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "de-latin1";
  };

  # Enable sound
  sound.enable = true;
  hardware.pulseaudio.enable = false;

  # Power management
  services.thermald.enable = true;
  powerManagement.enable = true;

  # Nix configuration
  nix = {
    package = pkgs.nixFlakes;
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "mk" ];

      # Configure binary caches
      substituters = [
        "https://cache.nixos.org"
        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="c=
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

    # System monitoring and management
    btop
    htop
    radeontop

    # Hardware support
    mesa
    libva
    rocm-opencl-icd
    rocm-opencl-runtime
    firmwareLinuxNonfree
    ddcutil

    # Network tools
    networkmanager
    networkmanagerapplet
    ntp

    # Audio/Video core
    pipewire
    wireplumber
    pipewire-pulse

    # Virtualization and containers
    podman
    podman-compose
    docker
    docker-compose
    distrobox
    slirp4netns
    fuse-overlayfs

    # Security tools
    age

    # Display manager and core desktop components
    lightdm
    lightdm-gtk-greeter
    plymouth
    libsForQt5.qt5.qtgraphicaleffects
    libsForQt5.qt5.qtquickcontrols2
    libsForQt5.qt5.qtsvg
    libsForQt5.sddm-kcm

    # Wayland core components
    wl-clipboard
    wlr-randr

    # System shells
    zsh
    tmux

    # Core development tools
    glibc
    lib32-glibc

    # System services
    syncthing
  ];

  # For AUR packages that need special handling
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };

  # Include NUR packages
  environment.systemPackages = with pkgs.nur.repos; [
    # Add AUR equivalents here
    # For example:
    # someuser.hyprlock
    # anotheruser.grimblast
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

    # NetworkManager
    networkmanager.enable = true;

    # Display Manager
    displayManager = {
      sddm = {
        enable = true;
        theme = "astronaut";
        settings = {
          Theme = {
            CursorTheme = "Adwaita";
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
      lightdm.enable = false;
    };

    # Docker
    docker = {
      enable = true;
      enableOnBoot = true;
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

  # Podman configuration
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # Add SDDM packages and Astronaut theme
  environment.systemPackages = with pkgs; [
    # Add to your existing packages
    libsForQt5.qt5.qtgraphicaleffects
    libsForQt5.qt5.qtquickcontrols2
    libsForQt5.qt5.qtsvg
    libsForQt5.sddm-kcm
  ];

  # Install the Astronaut theme using fetchGit (no hash needed)
  environment.etc."sddm/themes/astronaut" = {
    source = builtins.fetchGit {
      url = "https://github.com/totoro-ghost/sddm-astronaut.git";
      ref = "master";
    };
    recursive = true;
  };

  # Shell configuration
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  # For Wayland/Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # X11 keyboard layout
  services.xserver.layout = "de";
  services.xserver.xkbVariant = "nodeadkeys";

  boot = {
    initrd.kernelModules = [ "amdgpu" ];

    kernelModules = [ "amdgpu" ];

    kernelParams = [
      "amdgpu.ppfeaturemask=0xffffffff"
      "amdgpu.dc=1"
      "amdgpu.dpm=1"
    ];
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;

    extraPackages = with pkgs; [
      mesa
      libva
      rocm-opencl-icd
      rocm-opencl-runtime
    ];

    extraPackages32 = with pkgs.pkgsi686Linux; [
      mesa
      libva
    ];
  };

  environment.variables = {
    AMD_VULKAN_ICD = "RADV";
  };

  hardware.firmware = with pkgs; [
    firmwareLinuxNonfree
  ];

  services.pia = {
    enable = true;
  };
}
