{ config, pkgs, lib, system, zen-browser, ignis, ... }:

{
  home.username = "mk";
  home.homeDirectory = "/home/mk";

  home.stateVersion = "24.11";

  # User-specific packages
  home.packages = with pkgs; [
    # Browsers
    zen-browser.packages.${system}.default # beta
    bat
    eza
    ignis.packages.${system}.default
  ];

  programs.git = {
    enable = true;
    userEmail = "kaltschmidmichael@gmail.com";
    userName = "Michael Kaltschmid";
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
    initExtra = ''
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

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraConfig = ''
      set number relativenumber
    '';
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
    enable = true;
    config = ''
      // Niri configuration
      input {
          keyboard {
              xkb {
                  layout "de"
              }
          }

          focus-follows-mouse max-scroll-amount="20%"

          touchpad {
              tap
              natural-scroll
          }

          mouse {
              accel-speed 0.36
              accel-profile "flat"
              middle-emulation
          }
      }

      layout {
          always-center-single-column

          focus-ring {
              width 3
              active-gradient from="#80c8ff" to="#bbddff" angle=45
              inactive-gradient from="#505050" to="#808080" angle=45 relative-to="workspace-view"
          }
          border {
              off
          }

          preset-column-widths {
              proportion 0.33333
              proportion 0.5
              proportion 0.66667
          }
      }

      spawn-at-startup "ignis" "init"

      prefer-no-csd

      binds {
          // Terminal
          Mod+Return { spawn "kitty"; }

          // Window management
          Mod+Q { close-window; }

          // Focus navigation
          Mod+Left  { focus-column-left; }
          Mod+Down  { focus-window-down; }
          Mod+Up    { focus-window-up; }
          Mod+Right { focus-column-right; }
          Mod+H     { focus-column-left; }
          Mod+J     { focus-window-down; }
          Mod+K     { focus-window-up; }
          Mod+L     { focus-column-right; }
          Mod+Shift+WheelScrollDown { focus-window-down-or-top; }
          Mod+Shift+WheelScrollUp   { focus-window-up-or-bottom; }
          Mod+WheelScrollDown cooldown-ms=150 { focus-column-right; }
          Mod+WheelScrollUp   cooldown-ms=150 { focus-column-left; }
          Mod+Home { focus-column-first; }
          Mod+End  { focus-column-last; }

          // Window movement
          Mod+Ctrl+Left  { move-column-left; }
          Mod+Ctrl+Down  { move-window-down; }
          Mod+Ctrl+Up    { move-window-up; }
          Mod+Ctrl+Right { move-column-right; }
          Mod+Ctrl+H     { move-column-left; }
          Mod+Ctrl+J     { move-window-down; }
          Mod+Ctrl+K     { move-window-up; }
          Mod+Ctrl+L     { move-column-right; }
          Mod+Ctrl+Home { move-column-to-first; }
          Mod+Ctrl+End  { move-column-to-last; }

          // Monitor navigation
          Mod+Shift+Left  { focus-monitor-left; }
          Mod+Shift+Right { focus-monitor-right; }
          Mod+Shift+H     { focus-monitor-left; }
          Mod+Shift+J     { focus-monitor-down; }
          Mod+Shift+K     { focus-monitor-up; }
          Mod+Shift+L     { focus-monitor-right; }
          Mod+S     { expand-column-to-available-width; }

          // Monitor window movement
          Mod+Shift+Ctrl+Left  { move-column-to-monitor-left; }
          Mod+Shift+Ctrl+Down  { move-column-to-monitor-down; }
          Mod+Shift+Ctrl+Up    { move-column-to-monitor-up; }
          Mod+Shift+Ctrl+Right { move-column-to-monitor-right; }
          Mod+Shift+Ctrl+H     { move-column-to-monitor-left; }
          Mod+Shift+Ctrl+J     { move-column-to-monitor-down; }
          Mod+Shift+Ctrl+K     { move-column-to-monitor-up; }
          Mod+Shift+Ctrl+L     { move-column-to-monitor-right; }

          // Workspace navigation
          Mod+Page_Down      { focus-workspace-down; }
          Mod+Page_Up        { focus-workspace-up; }
          Mod+U              { focus-workspace-down; }
          Mod+I              { focus-workspace-up; }
          Mod+Ctrl+Page_Down { move-column-to-workspace-down; }
          Mod+Ctrl+Page_Up   { move-column-to-workspace-up; }
          Mod+Ctrl+U         { move-column-to-workspace-down; }
          Mod+Ctrl+I         { move-column-to-workspace-up; }
          Mod+Shift+Page_Down { move-workspace-down; }
          Mod+Shift+Page_Up   { move-workspace-up; }
          Mod+Shift+U         { move-workspace-down; }
          Mod+Shift+I         { move-workspace-up; }

          // Workspace selection
          Mod+1 { focus-workspace 1; }
          Mod+2 { focus-workspace 2; }
          Mod+3 { focus-workspace 3; }
          Mod+4 { focus-workspace 4; }
          Mod+5 { focus-workspace 5; }
          Mod+6 { focus-workspace 6; }
          Mod+7 { focus-workspace 7; }
          Mod+8 { focus-workspace 8; }
          Mod+9 { focus-workspace 9; }
          Mod+Ctrl+1 { move-column-to-workspace 1; }
          Mod+Ctrl+2 { move-column-to-workspace 2; }
          Mod+Ctrl+3 { move-column-to-workspace 3; }
          Mod+Ctrl+4 { move-column-to-workspace 4; }
          Mod+Ctrl+5 { move-column-to-workspace 5; }
          Mod+Ctrl+6 { move-column-to-workspace 6; }
          Mod+Ctrl+7 { move-column-to-workspace 7; }
          Mod+Ctrl+8 { move-column-to-workspace 8; }
          Mod+Ctrl+9 { move-column-to-workspace 9; }

          // Column management
          Mod+Comma  { consume-window-into-column; }
          Mod+Period { expel-window-from-column; }
          Mod+Shift+A { consume-or-expel-window-left; }
          Mod+Shift+D { consume-or-expel-window-right; }
          Mod+R { switch-preset-column-width; }
          Mod+Control+F { maximize-column; }
          Mod+Shift+F { fullscreen-window; }
          Mod+C { center-column; }
          Mod+Space { spawn "walker"; }

          // Size adjustments
          Mod+Minus { set-column-width "-10%"; }
          Mod+Plus { set-column-width "+10%"; }
          Mod+Shift+Minus { set-window-height "-10%"; }
          Mod+Shift+Equal { set-window-height "+10%"; }

          // Screenshots
          Print { screenshot; }
          Ctrl+Print { screenshot-screen; }
          Alt+Print { screenshot-window; }

          // Volume controls
          XF86AudioRaiseVolume {
              spawn "sh" "-c" "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05+ && ignis open ignis_OSD";
          }

          XF86AudioLowerVolume {
              spawn "sh" "-c" "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05- && ignis open ignis_OSD";
          }

          Mod+Shift+Up {
              spawn "sh" "-c" "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05+ && ignis open ignis_OSD";
          }

          Mod+Shift+Down {
              spawn "sh" "-c" "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05- && ignis open ignis_OSD";
          }

          // Exit niri
          Mod+Shift+e { quit; }
      }
    '';
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

  # Qt theming to match GTK
  qt = {
    enable = true;
    platformTheme = "gtk";
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

  systemd.user.services.easyeffects = {
    Unit = {
      Description = "Easyeffects daemon";
      Requires = [ "dbus.service" ];
      After = [ "graphical-session.target" ];
      PartOf = [
        "graphical-session.target"
        "pipewire.service"
      ];
    };

    Install.WantedBy = [ "graphical-session.target" ];

    Service = {
      ExecStart = "${pkgs.easyeffects}/bin/easyeffects --gapplication-service";
      ExecStop = "${pkgs.easyeffects}/bin/easyeffects --quit";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  home.activation.dots = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p $HOME/Documents/repos/dotfiles
    if [ ! -d $HOME/Documents/repos/dotfiles/.git ]; then
      ${pkgs.git}/bin/git clone -b chezmoi https://github.com/dixn/dotfiles.git $HOME/Documents/repos/dotfiles
    else
      cd $HOME/Documents/repos/dotfiles && ${pkgs.git}/bin/git pull --rebase
    fi

    mkdir -p $HOME/Documents
    for script in $HOME/Documents/repos/dotfiles/Documents/executable_*; do
      if [ -f "$script" ]; then
        new_name=$(basename "$script" | sed 's/^executable_//')
        cp "$script" "$HOME/Documents/$new_name"
        chmod +x "$HOME/Documents/$new_name"
      fi
    done

    # Create pictures directory and copy wallpapers
    mkdir -p $HOME/Pictures/wallpapers
    if [ -d $HOME/Documents/repos/dotfiles/Pictures/wallpapers ]; then
      cp -r $HOME/Documents/repos/dotfiles/Pictures/wallpapers/* $HOME/Pictures/wallpapers/
    fi
  '';

  home.activation.ignis = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Create temporary directory for cloning
    TEMP_DIR=$(mktemp -d)

    # Clone the repository
    ${pkgs.git}/bin/git clone https://github.com/linkfrg/dotfiles.git $TEMP_DIR

    # Create ignis directory in ~/.config
    mkdir -p $HOME/.config/ignis

    # Copy the ignis folder to ~/.config
    cp -r $TEMP_DIR/ignis/* $HOME/.config/ignis/

    # Remove specified lines from config.py
    if [ -f "$HOME/.config/ignis/config.py" ]; then
      ${pkgs.gnused}/bin/sed -i '/Utils\.exec_sh("gsettings set org\.gnome\.desktop\.interface gtk-theme Material")/d' $HOME/.config/ignis/config.py
      ${pkgs.gnused}/bin/sed -i '/Utils\.exec_sh("gsettings set org\.gnome\.desktop\.interface icon-theme Papirus")/d' $HOME/.config/ignis/config.py

      ${pkgs.gnused}/bin/sed -i '/Utils\.exec_sh(.*font-name/,/)/d' $HOME/.config/ignis/config.py

      ${pkgs.gnused}/bin/sed -i '/Utils\.exec_sh("hyprctl reload")/d' $HOME/.config/ignis/config.py
    fi

    # Clean up temporary directory
    rm -rf $TEMP_DIR
  '';
}
