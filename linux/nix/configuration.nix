{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Basic system configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.plymouth.enable = true;

  # User configuration
  users.users.mk = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "input" "autologin" "docker" "networkmanager" ];
    shell = pkgs.zsh;
    initialPassword = "mk";
  };
  security.sudo.wheelNeedsPassword = false;

  # Package management (from essentials.sh)
  environment.systemPackages = with pkgs; [
    # Basic utilities
    nsxiv
    rclone
    bat
    mpv
    networkmanagerapplet
    zathura
    zathura-poppler-pdf
    scrcpy
    python3
    python3Packages.dbus-python
    openssh
    neofetch
    neovim
    micro
    kitty
    rsync
    nfs-utils
    unclutter

    # Audio/Video
    pipewire
    wireplumber
    pipewire-pulse

    # Wayland tools
    wl-clipboard
    grim
    slurp
    wlr-randr

    # File managers and GUI tools
    gnome.nautilus
    alacritty
    lazygit
    dust
    nitrogen
    pamixer

    # Python packages
    python3Packages.pynvim

    # File utilities
    eza
    htop
    typst

    # Fonts
    cantarell-fonts
    shellcheck
    jq
    yq
    fira-code
    fira-code-nerdfont
    fzf

    # System tools
    kexec-tools
    less
    tree
    broot
    playerctl

    # Themes
    arc-theme
    papirus-icon-theme
    btop

    # Security and utilities
    age
    expect
    zenity

    # Applications
    podman
    podman-compose
    easyeffects
    jellyfin-media-player
    pavucontrol
    radeontop
    hyperfine
    github-cli
    thunderbird
    ddcutil

    # Network tools
    ntp

    # From essentials.sh
    networkmanager
    lightdm
    lightdm-gtk-greeter
    plymouth
    docker
    docker-compose
    syncthing
    zsh
    tmux
    antibody
    lua
    piavpn

    # From init.sh
    git
    chezmoi
    glibc
    lib32-glibc
    rustup
    dotnet-sdk_6
    dotnet-runtime_6
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
    # Add to your existing services
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };

  # Services from essentials.sh
  services = {
    # NetworkManager
    networkmanager.enable = true;

    # SDDM configuration
    displayManager = {
      sddm = {
        enable = true;
        theme = "breeze";
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
      # Disable LightDM
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

  # Podman configuration (from essentials.sh)
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

  # Install and configure Astronaut theme for SDDM
  services.displayManager.sddm = {
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

  # Install the Astronaut theme using fetchGit (no hash needed)
  environment.etc."sddm/themes/astronaut" = {
    source = builtins.fetchGit {
      url = "https://github.com/totoro-ghost/sddm-astronaut.git";
      ref = "master";
    };
    recursive = true;
  };

  # Disable LightDM
  services.displayManager.lightdm.enable = false;

  # Copy wallpaper for SDDM
  environment.etc."sddm/backgrounds/wallpaper.jpg" = {
    source = "${config.users.users.mk.home}/Pictures/wallpapers/4.jpg";
    mode = "0644";
  };

  # Shell configuration
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Console keymap
  console.keyMap = "de-latin1";

  # X11 keyboard layout
  services.xserver.layout = "de";
  services.xserver.xkbVariant = "nodeadkeys";

  # For Wayland/Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Enable flakes and other nix features
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "root" "mk" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
}
