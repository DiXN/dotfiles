{ config, pkgs, lib, system, zen-browser, dots-repo, dms, quickshell, ... }:

{
  home.username = "mk";
  home.homeDirectory = "/home/mk";

  home.stateVersion = "26.05";

  nix.settings = {
    substituters = [
      "https://cache.nixos.org"
      "https://niri.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
    ];
  };

  home.packages = with pkgs; [
    bat
    eza
    walker
    xwayland-satellite
    nixvim
    xsel
    nautilus
  ];

  programs.zen-browser = {
    enable = true;

    policies = {
      AutofillAddressEnabled = true;
      AutofillCreditCardEnabled = false;
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;

      ExtensionSettings = with builtins;
        let extension = shortId: uuid: {
          name = uuid;
          value = {
            install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
            installation_mode = "normal_installed";
          };
        };
        in listToAttrs [
          (extension "ublock-origin" "uBlock0@raymondhill.net")
          (extension "bitwarden-password-manager" "{446900e4-71c2-419f-a6a7-df9c091e268b}")
        ];
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        email = "kaltschmidmichael@gmail.com";
        name = "Michael Kaltschmid";
      };
    };
  };

  programs.lazygit = {
    enable = true;
  };

  # Zsh configuration
  programs.zsh = {
    enable = true;
    history = {
      size = 10000;
      save = 10000;
      ignoreDups = true;
      share = true;
    };
    shellAliases = {
      ec = "$EDITOR $HOME/.zshrc";
      sc = "source $HOME/.zshrc";
      ze = "z -e";
      ads = "$HOME/Documents/androidshare.sh";
      bd = "$HOME/Documents/brightness.sh down";
      bu = "$HOME/Documents/brightness.sh up";
      eb = "sudo nvim /usr/bin/instantstatus";
      v = "nvim";
      sv = "sudo nvim";
      du = "dust";
      scp = "rsync -ah --progress";
      docker = "podman";
      vlang = "/usr/bin/v";
      la = "exa --icons -l -a";
    };
    initContent = ''
      # Configure prompt
      prompt_context() {}

      export BAT_THEME="ansi-dark"

      function spell() {
        bash "$HOME/Documents/spell.sh $1"
      }

      # Key bindings
      function up-directory() {
        cd ..
        zle reset-prompt
      }
      zle -N up-directory
      bindkey '^x' up-directory

      function opennewterm() {
        st >/dev/null 2>&1 & disown
      }
      zle -N opennewterm
      bindkey -s '^y' "opennewterm\n"

      # Enable HOME and END key
      bindkey  "^[[1~"   beginning-of-line
      bindkey  "^[[4~"   end-of-line
      bindkey  "^[[3~"   delete-char

      bindkey  "^[[H"   beginning-of-line
      bindkey  "^[[F"   end-of-line

      # Source p10k config if it exists
      POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
      [[ ! -f $HOME/.config/zsh/.p10k.zsh ]] || source $HOME/.config/zsh/.p10k.zsh
    '';

    syntaxHighlighting.enable = true;
    antidote = {
      enable = true;
      plugins = [
        "romkatv/powerlevel10k"
        "zsh-users/zsh-syntax-highlighting"
        "zsh-users/zsh-autosuggestions"
        "zsh-users/zsh-history-substring-search"
        "ohmyzsh/ohmyzsh path:plugins/z"
        "ohmyzsh/ohmyzsh path:plugins/git"
      ];
    };
  };

  programs.hyprlock.enable = true;

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  # Wezterm configuration
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require 'wezterm'

      return {
          font = wezterm.font 'Fira Code Nerd Font Mono',
          font_size = 11.0,
          default_prog = { '/bin/zsh' },
          window_background_opacity = 0.9,
          color_scheme = 'Abernathy',
          warn_about_missing_glyphs = false,
          colors = {
              background = '#3c3d4b'
          },
          window_padding = {
              left = 4,
              right = 4,
              top = 4,
              bottom = 4,
          },
          max_fps = 60,
          hide_tab_bar_if_only_one_tab = true,
          ssh_domains = {
              {
                  name = 'nas',
                  username = 'admin',
                  multiplexing = 'None',
                  remote_address = '10.0.0.5',
                  ssh_option = {
                      identityfile = '~/.ssh/nas',
                  },
              },
          },
      }
    '';
  };

  # Kitty terminal configuration
  programs.kitty = {
    enable = true;
    settings = {
      copy_on_select = "yes";
      enable_audio_bell = "no";
      sync_to_monitor = "yes";
      background_opacity = "0.9";
      background = "#3c3d4b";
      font_family = "Fira Code Nerd Font Mono";
      font_size = "12";
      mouse_enabled = "yes";
    };
  };

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

  programs.niri = {
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
        { argv = [ "dms" "run" ]; }
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
        "Mod+B".action.spawn = "zen";
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
        # "Mod+Shift+L".action.focus-monitor-right = [];
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
        "Mod+Shift+L" = {
          allow-inhibiting = false;
          action.spawn = [ "dms" "ipc" "call" "lock" "lock" ];
        };
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

  # services.easyeffects.enable = true;

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

  # For applications that use Electron
  xdg.configFile."electron-flags.conf".text = ''
    --force-dark-mode
  '';

  programs.dank-material-shell = {
    enable = true;

    settings = {
      currentThemeName = "dynamic";
      currentThemeCategory = "dynamic";

      popupTransparency = 0.92;
      dockTransparency = 0.75;
      widgetBackgroundColor = "sth";

      cornerRadius = 12;

      animationSpeed = 2;

      centeringMode = "geometric";

      fontScale = 1.15;

      useAutoLocation = true;
      networkPreference = "ethernet";

      launcherLogoMode = "os";

      showDock = true;
      dockSmartAutoHide = true;
      dockGroupByApp = true;
      dockPosition = 3;
      dockMargin = 10;
      dockLauncherEnabled = true;

      notificationOverlayEnabled = true;

      mediaSize = 2;
      spotlightModalViewMode = "grid";

      showWorkspaceApps = true;
      runningAppsCurrentWorkspace = false;

      barConfigs = [
        {
          id = "default";
          name = "Main Bar";
          enabled = true;
          position = 0;
          screenPreferences = [ "all" ];
          showOnLastDisplay = true;
          leftWidgets = [
            { id = "launcherButton"; enabled = true; }
            { id = "workspaceSwitcher"; enabled = true; }
            { id = "focusedWindow"; enabled = true; }
          ];
          centerWidgets = [
            { id = "music"; enabled = true; }
            { id = "clock"; enabled = true; }
            { id = "weather"; enabled = true; }
          ];
          rightWidgets = [
            { id = "privacyIndicator"; enabled = true; }
            { id = "systemTray"; enabled = true; }
            { id = "clipboard"; enabled = true; }
            { id = "notificationButton"; enabled = true; }
            { id = "battery"; enabled = true; }
            { id = "cpuUsage"; enabled = true; }
            { id = "controlCenterButton"; enabled = true; }
          ];
          spacing = 4;
          innerPadding = 8;
          bottomGap = 4;
          widgetTransparency = 0.85;
          borderEnabled = true;
          borderColor = "secondary";
          borderThickness = 1;
          fontScale = 1.15;
          showOnWindowsOpen = true;
          openOnOverview = true;
          maximizeDetection = true;
          clickThrough = true;
        }
      ];
    };

    niri = {
      enableKeybinds = false;
      enableSpawn = false;

      includes = {
        enable = false;
        override = true;
        originalFileName = "hm";
        filesToInclude = [
          "alttab"
          "binds"
          "colors"
          "layout"
          "outputs"
          "wpblur"
        ];
      };
    };

    enableSystemMonitoring = true;
    quickshell.package = quickshell.packages.${system}.default;
  };

  # systemd.user.services.niri-flake-polkit.enable = false;

  home.file."Documents/repos/dotfiles".source = dots-repo;

  home.file."Pictures/wallpapers".source = "${dots-repo}/Pictures/wallpapers";

  home.activation.dotsScripts = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p $HOME/Documents
    for script in $HOME/Documents/repos/dotfiles/Documents/executable_*; do
      if [ -f "$script" ]; then
        new_name=$(basename "$script" | sed 's/^executable_//')
        cp "$script" "$HOME/Documents/$new_name"
        chmod +x "$HOME/Documents/$new_name"
      fi
    done
  '';

  home.activation.walker = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -d "$HOME/.config/walker" ]; then
      ${pkgs.walker}/bin/walker -C
    fi
  '';

  # Script to create user.js in the correct Zen browser profile directory
  home.activation.zenUserJs = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ZEN_CONFIG_DIR="$HOME/.zen"

    if [ -d "$ZEN_CONFIG_DIR" ]; then
      # Find all directories in .zen that contain a prefs.js file
      find "$ZEN_CONFIG_DIR" -type f -name "prefs.js" | while read -r prefs_file; do
        profile_dir=$(dirname "$prefs_file")
        echo "Creating user.js in Zen browser profile: $profile_dir"

        # Create user.js with inline content
        cat > "$profile_dir/user.js" << 'EOF'
// user.js for Zen Browser
// This file contains user preferences that override default settings

// Privacy & Security
user_pref("privacy.donottrackheader.enabled", true);
user_pref("privacy.trackingprotection.enabled", true);
user_pref("privacy.trackingprotection.socialtracking.enabled", true);
user_pref("privacy.partition.network_state.ocsp_cache", true);
user_pref("privacy.resistFingerprinting", true);

// Performance
user_pref("browser.cache.disk.enable", true);
user_pref("browser.cache.memory.enable", true);
user_pref("browser.sessionstore.interval", 15000);

// UI/UX
user_pref("browser.tabs.loadInBackground", true);
user_pref("browser.urlbar.suggest.searches", true);
user_pref("browser.urlbar.suggest.history", true);
user_pref("browser.urlbar.suggest.bookmark", true);
user_pref("browser.urlbar.suggest.openpage", true);

// Zen Browser specific
user_pref("zen.view.sidebar-expanded", false);
user_pref("zen.view.sidebar-expanded.on-hover", false);
user_pref("zen.welcome-screen.seen", true);

// Add your custom configurations below
EOF
      done
    else
      echo "Zen browser config directory not found at $ZEN_CONFIG_DIR, skipping user.js setup"
    fi
  '';
}
