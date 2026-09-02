{ config, pkgs, ... }:

{
  programs.niri = {
    package = pkgs.niri;
    settings = {
      input = {
        keyboard.xkb.layout = "de";
        focus-follows-mouse.enable = true;
        focus-follows-mouse.max-scroll-amount = "20%";
        touchpad.tap = true;
        touchpad.natural-scroll = true;
        mouse.accel-speed = 0.36;
        mouse.accel-profile = "flat";
        mouse.middle-emulation = true;
      };

      layout = {
        always-center-single-column = true;
        focus-ring = {
          width = 3;
          active.gradient = {
            from = "#80c8ff";
            to = "#bbddff";
            angle = 45;
          };
          inactive.gradient = {
            from = "#505050";
            to = "#808080";
            angle = 45;
            relative-to = "workspace-view";
          };
        };
        border.enable = false;
        default-column-width.proportion = 0.5;
        gaps = 4;
        preset-column-widths = [
          { proportion = 0.33333; }
          { proportion = 0.5; }
          { proportion = 0.66667; }
        ];
        tab-indicator = {
          hide-when-single-tab = true;
          place-within-column = true;
          gap = 5;
          width = 4;
          length.total-proportion = 1.0;
          position = "left";
          gaps-between-tabs = 2;
          corner-radius = 8;
          active.color = "yellow";
          inactive.color = "gray";
        };
        default-column-display = "tabbed";
        shadow.enable = true;
      };
      spawn-at-startup = [
        { argv = [ "sh" "-c" "xwayland-satellite --server $WAYLAND_DISPLAY" ]; }
      ];

      environment = {
        QT_QPA_PLATFORM = "wayland";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
        DISPLAY = ":0";
      };

      prefer-no-csd = true;

      binds = {
        "Mod+Return".action.spawn = "kitty";
        "Mod+F".action.spawn = "nautilus";
        "Mod+B".action.spawn = "zen-beta";
        "Mod+Q".action.close-window = [];
        "Mod+Left".action.focus-column-left = [];
        "Mod+Down".action.focus-window-down = [];
        "Mod+Up".action.focus-window-up = [];
        "Mod+Right".action.focus-column-right = [];
        "Mod+H".action.focus-column-left = [];
        "Mod+J".action.focus-window-down = [];
        "Mod+K".action.focus-window-up = [];
        "Mod+L".action.focus-column-right = [];
        "Mod+Shift+WheelScrollDown".action.focus-window-down-or-top = [];
        "Mod+Shift+WheelScrollUp".action.focus-window-up-or-bottom = [];
        "Mod+WheelScrollDown" = {
          cooldown-ms = 150;
          action.focus-column-right = [];
        };
        "Mod+WheelScrollUp" = {
          cooldown-ms = 150;
          action.focus-column-left = [];
        };
        "Mod+Home".action.focus-column-first = [];
        "Mod+End".action.focus-column-last = [];
        "Mod+Ctrl+Left".action.move-column-left = [];
        "Mod+Ctrl+Down".action.move-window-down = [];
        "Mod+Ctrl+Up".action.move-window-up = [];
        "Mod+Ctrl+Right".action.move-column-right = [];
        "Mod+Ctrl+H".action.move-column-left = [];
        "Mod+Ctrl+J".action.move-window-down = [];
        "Mod+Ctrl+K".action.move-window-up = [];
        "Mod+Ctrl+L".action.move-column-right = [];
        "Mod+Ctrl+Home".action.move-column-to-first = [];
        "Mod+Ctrl+End".action.move-column-to-last = [];
        "Mod+Shift+Left".action.focus-monitor-left = [];
        "Mod+Shift+Right".action.focus-monitor-right = [];
        "Mod+Shift+H".action.focus-monitor-left = [];
        "Mod+Shift+J".action.focus-monitor-down = [];
        "Mod+Shift+K".action.focus-monitor-up = [];
        "Mod+Shift+L" = {
          allow-inhibiting = false;
          action.spawn = [ "dms" "ipc" "call" "lock" "lock" ];
        };
        "Mod+S".action.expand-column-to-available-width = [];
        "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = [];
        "Mod+Shift+Ctrl+Down".action.move-window-to-monitor-down = [];
        "Mod+Shift+Ctrl+Up".action.move-window-to-monitor-up = [];
        "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = [];
        "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = [];
        "Mod+Shift+Ctrl+J".action.move-window-to-monitor-down = [];
        "Mod+Shift+Ctrl+K".action.move-window-to-monitor-up = [];
        "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = [];
        "Mod+Page_Down".action.focus-workspace-down = [];
        "Mod+Page_Up".action.focus-workspace-up = [];
        "Mod+U".action.focus-workspace-down = [];
        "Mod+I".action.focus-workspace-up = [];
        "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = [];
        "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = [];
        "Mod+Ctrl+U".action.move-column-to-workspace-down = [];
        "Mod+Ctrl+I".action.move-column-to-workspace-up = [];
        "Mod+Shift+Page_Down".action.move-workspace-down = [];
        "Mod+Shift+Page_Up".action.move-workspace-up = [];
        "Mod+Shift+U".action.move-workspace-down = [];
        "Mod+Shift+I".action.move-workspace-up = [];
        "Mod+1".action.focus-workspace = 1;
        "Mod+2".action.focus-workspace = 2;
        "Mod+3".action.focus-workspace = 3;
        "Mod+4".action.focus-workspace = 4;
        "Mod+5".action.focus-workspace = 5;
        "Mod+6".action.focus-workspace = 6;
        "Mod+7".action.focus-workspace = 7;
        "Mod+8".action.focus-workspace = 8;
        "Mod+9".action.focus-workspace = 9;
        "Mod+Ctrl+1".action.move-column-to-workspace = 1;
        "Mod+Ctrl+2".action.move-column-to-workspace = 2;
        "Mod+Ctrl+3".action.move-column-to-workspace = 3;
        "Mod+Ctrl+4".action.move-column-to-workspace = 4;
        "Mod+Ctrl+5".action.move-column-to-workspace = 5;
        "Mod+Ctrl+6".action.move-column-to-workspace = 6;
        "Mod+Ctrl+7".action.move-column-to-workspace = 7;
        "Mod+Ctrl+8".action.move-column-to-workspace = 8;
        "Mod+Ctrl+9".action.move-column-to-workspace = 9;
        "Mod+Comma".action.consume-window-into-column = [];
        "Mod+Period".action.expel-window-from-column = [];
        "Mod+Shift+A".action.consume-or-expel-window-left = [];
        "Mod+Shift+D".action.consume-or-expel-window-right = [];
        "Mod+R".action.switch-preset-column-width = [];
        "Mod+Ctrl+F".action.maximize-column = [];
        "Mod+Shift+F".action.fullscreen-window = [];
        "Mod+C".action.center-column = [];
        "Mod+Space" = {
          hotkey-overlay.title = "Application Launcher";
          action.spawn = [ "dms" "ipc" "call" "spotlight" "toggle" ];
        };
        "Mod+Alt+Space".action.spawn = "walker";
        "Mod+Minus".action.set-column-width = ["-10%"];
        "Mod+Plus".action.set-column-width = ["+10%"];
        "Mod+Shift+Minus".action.set-window-height = ["-10%"];
        "Mod+Shift+Equal".action.set-window-height = ["+10%"];
        "Print".action.screenshot = [];
        "Ctrl+Print".action.screenshot-screen = [];
        "Alt+Print".action.screenshot-window = [];
        "Mod+O".action.toggle-overview = [];
        "Mod+M" = {
          hotkey-overlay.title = "Task Manager";
          action.spawn = [ "dms" "ipc" "call" "processlist" "toggle" ];
        };
        "XF86AudioRaiseVolume".action.spawn = [ "dms" "ipc" "call" "audio" "increment" "3" ];
        "XF86AudioLowerVolume".action.spawn = [ "dms" "ipc" "call" "audio" "decrement" "3" ];
        "Mod+Shift+Up".action.spawn = [ "sh" "-c" "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05+ && ignis open ignis_OSD" ];
        "Mod+Shift+Down".action.spawn = [ "sh" "-c" "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05- && ignis open ignis_OSD" ];
        "Mod+Shift+E".action.quit = [];
      };
    };
  };
}
