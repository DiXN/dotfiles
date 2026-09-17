{ pkgs, ... }:

let
  faugusConfig = pkgs.writeText "faugus-config.json" (builtins.toJSON {
    default-prefix = "/home/mk/.wine";
    mangohud = "True";
    gamemode = "False";
    sc-controller = "False";
    default-runner = "Proton-GE Latest";
    discrete-gpu = "True";
    system-tray = "True";
    interface-mode = "List";
    start-maximized = "False";
    api-key = "";
    start-fullscreen = "False";
    gamepad-navigation = "False";
    prefer-sdl = "False";
    lossless-location = "";
    mono-icon = "False";
    smaller-banners = "True";
    wayland-driver = "True";
    enable-hdr = "False";
    enable-ntsync = "True";
    language = "en_US";
    logging-warning = "True";
    show-hidden = "False";
    show-donate = "True";
    donate-last = "2026-09";
    playtime = "0";
    backup-auto-enabled = "False";
    backup-frequency = "daily";
    backup-target-day = "0";
    backup-dest-dir = "";
    backup-last-date = "";
    width = "1280";
    height = "720";
    sort = "alpha";
    category = "all";
    interface-theme = "system";
    accent-color = "system";
    steamgriddb-api-key = "";
    background-mode = "default";
    steam-user = "all";
    banner-enabled = "True";
    cover-size = "100";
    sdl-enabled = "False";
    no-sleep-enabled = "False";
    auto-close-on-launch = "False";
    labels-enabled = "True";
    logging-enabled = "False";
    autostart-enabled = "False";
    minimized-startup-enabled = "False";
    wow64-enabled = "True";
    startup-window-size = "None";
    categories-enabled = "False";
    sort-enabled = "False";
    splash-window-enabled = "True";
    automatic-updates = "True";
    zoom-enabled = "True";
    header-bar = "False";
    theme-engine = "adwaita";
    steamgriddb-enabled = "False";
    categories-and-sort-enabled = "False";
  });
  faugusEnvar = pkgs.writeText "faugus-envar.json" "[]";
in
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.steam-hardware.enable = true;

  programs.steam = {
    enable = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
  };

  systemd.tmpfiles.rules = [
    "d /home/mk/.local 0755 mk users -"
    "d /home/mk/.config 0755 mk users -"
    "d /home/mk/.local/share 0755 mk users -"
    "d /home/mk/.local/share/Steam 0755 mk users -"
    "d /home/mk/.local/share/Steam/steamapps/common 0755 mk users -"
    "d /home/mk/.config/faugus-launcher 0755 mk users -"
    "C /home/mk/.config/faugus-launcher/config.json 0600 mk users - ${faugusConfig}"
    "C /home/mk/.config/faugus-launcher/envar.json 0600 mk users - ${faugusEnvar}"
  ];

  environment.systemPackages = with pkgs; [
    wineWow64Packages.stable
    winetricks
    steam-run
    faugus-launcher
    umu-launcher
  ];
}
