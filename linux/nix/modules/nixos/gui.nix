{ pkgs, ... }:

{
  home-manager.users.mk.imports = [
    ../home/niri.nix
    ../home/dms.nix
    ../home/zen.nix
    ../home/terminals.nix
    ../home/desktop.nix
  ];

  services.pulseaudio.enable = false;

  # Pipewire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Display Manager
  services.displayManager = {
    dms-greeter = {
      enable = true;
      compositor.name = "niri";
    };
    # sddm = {
    #   enable = true;
    #   theme = "astronaut";
    #   wayland.enable = true;
    #   settings = {
    #     Theme = {
    #       Font = "Cantarell 10";
    #     };
    #     Users = {
    #       DefaultUser = "mk";
    #     };
    #     Wayland = {
    #       EnableHiDPI = true;
    #     };
    #   };
    # };
    # Add Niri to the session packages
    sessionPackages = [ pkgs.niri ];
  };

  programs.niri.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  xdg.portal.config.common.default = "*";

  programs.dconf.enable = true;

  # X11 keyboard layout
  services.xserver.xkb = {
    layout = "de";
    variant = "nodeadkeys";
  };

  # Power management
  services.upower.enable = true;
  services.thermald.enable = true;
  powerManagement.enable = true;

  # Package management (system-wide packages)
  environment.systemPackages = with pkgs; [
    cantarell-fonts

    (pkgs.callPackage ./sddm-astronaut.nix {
      themeConfig = {
        # Optional theme configuration
        # Background = "/path/to/background.jpg";
      };
    })
  ];
}
