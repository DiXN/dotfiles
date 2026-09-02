{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    walker
    xsel
    nautilus
  ];

  programs.hyprlock.enable = true;

  # MangoHud configuration
  programs.mangohud = {
    enable = true;
    settings = {
      legacy_layout = false;
      gpu_stats = true;
      gpu_temp = true;
      gpu_core_clock = true;
      gpu_mem_clock = true;
      gpu_power = true;
      gpu_load_change = true;
      gpu_load_value = [50 90];
      gpu_load_color = ["FFFFFF" "FF7800" "CC0000"];
      gpu_text = "GPU";
      cpu_stats = true;
      cpu_temp = true;
      core_load = true;
      cpu_color = "2e97cb";
      cpu_text = "CPU";
      io_color = "a491d3";
      vram = true;
      vram_color = "ad64c1";
      ram_color = "c26693";
      fps = true;
      engine_color = "eb5b5b";
      gpu_name = true;
      gpu_color = "2e9762";
      vulkan_driver = true;
      wine_color = "eb5b5b";
      frame_timing = 1;
      frametime_color = "00ff00";
      resolution = true;
      vkbasalt = true;
      gamemode = true;
      media_player_color = "ffffff";
      time = true;
      background_alpha = 0.4;
      font_size = 24;
      background_color = "020202";
      position = "top-left";
      text_color = "ffffff";
      round_corners = 0;
      toggle_hud = "Shift_R+F12";
      toggle_logging = "Shift_L+F2";
      upload_log = "F5";
      output_folder = "/home/mk";
      media_player_name = "spotify";
      toggle_fps_limit = "F1";
    };
  };

  # GTK theming for dark mode
  gtk = {
    enable = true;
    theme = {
      name = "Arc-Dark";
      package = pkgs.arc-theme;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  xdg.configFile = {
    "gtk-4.0/assets".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
    "gtk-4.0/gtk.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
    "gtk-4.0/gtk-dark.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";

    # Removed external user.js file in favor of inline content in the activation script

    # For applications that use Electron
    "electron-flags.conf".text = ''
      --force-dark-mode
    '';
  };

  # Qt theming to match GTK
  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

  # Dark mode for various applications
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Arc-Dark";
      icon-theme = "Papirus-Dark";
    };
    "org/gnome/desktop/wm/preferences" = {
      theme = "Arc-Dark";
    };
  };
}
