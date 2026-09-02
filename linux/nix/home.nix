{ config, pkgs, lib, system, zen-browser, dots-repo, dms, quickshell, ... }:

{
  imports = [
    ./modules/home/niri.nix
    ./modules/home/dms.nix
  ];

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

      ExtensionSettings = builtins.mapAttrs (_: install_url: {
        inherit install_url;
        installation_mode = "normal_installed";
      }) {
        "uBlock0@raymondhill.net" = "https://addons.mozilla.org/firefox/downloads/file/4981431/ublock_origin-1.74.0.xpi";
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = "https://addons.mozilla.org/firefox/downloads/file/4875950/bitwarden_password_manager-2026.6.1.xpi";
        "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = "https://addons.mozilla.org/firefox/downloads/file/4371820/return_youtube_dislikes-3.0.0.18.xpi";
        "videoresumer@jetpack" = "https://addons.mozilla.org/firefox/downloads/file/4270451/video_resumer-1.2.4resigned1.xpi";
        "BraveSearchExtension@io.Uvera" = "https://addons.mozilla.org/firefox/downloads/file/4278495/brave_search-1.3.0.xpi";
        "{6505e807-3fe7-447e-99df-1f2aa51b443f}" = "https://addons.mozilla.org/firefox/downloads/file/4376806/indexeddb_manager-0.0.1.xpi";
        "{bd490218-d863-45c9-8ffa-490ba0a91577}" = "https://addons.mozilla.org/firefox/downloads/file/4466501/rotate_image-2.0.0.xpi";
        "side-view@mozilla.org" = "https://addons.mozilla.org/firefox/downloads/file/4371246/side_view-0.6.6956.xpi";
        "nordvpnproxy@nordvpn.com" = "https://addons.mozilla.org/firefox/downloads/file/4638627/nordvpn_proxy_extension-5.2.2.xpi";
        "myallychou@gmail.com" = "https://addons.mozilla.org/firefox/downloads/file/4733035/youtube_recommended_videos-1.6.9.xpi";
        "firefox@tampermonkey.net" = "https://addons.mozilla.org/firefox/downloads/file/4797143/tampermonkey-5.5.0.xpi";
        "@testpilot-containers" = "https://addons.mozilla.org/firefox/downloads/file/4867303/multi_account_containers-8.3.8.xpi";
        "enhancerforyoutube@maximerf.addons.mozilla.org" = "https://addons.mozilla.org/firefox/downloads/file/4933627/enhancer_for_youtube-2.0.136.xpi";
        "unhook-reddit@example.com" = "https://addons.mozilla.org/firefox/downloads/file/4750081/unhook_for_reddit-1.2.3.xpi";
        "webextension@metamask.io" = "https://addons.mozilla.org/firefox/downloads/file/4963931/ether_metamask-13.44.0.0.xpi";
        "languagetool-webextension@languagetool.org" = "https://addons.mozilla.org/firefox/downloads/file/4958761/languagetool-11.3.1.xpi";
        "{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}" = "https://addons.mozilla.org/firefox/downloads/file/4998329/refined_github-26.9.xpi";
      };
    };

    profiles.mk = {
      isDefault = true;
      id = 0;
      settings = {
        "privacy.donottrackheader.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "privacy.partition.network_state.ocsp_cache" = true;
        "privacy.resistFingerprinting" = true;

        "browser.cache.disk.enable" = true;
        "browser.cache.memory.enable" = true;
        "browser.sessionstore.interval" = 15000;
        "browser.startup.homepage" = "https://rss.kaltschm.id/i/";
        "browser.tabs.loadInBackground" = true;
        "browser.urlbar.suggest.searches" = true;
        "browser.urlbar.suggest.history" = true;
        "browser.urlbar.suggest.bookmark" = true;
        "browser.urlbar.suggest.openpage" = true;

        "zen.view.sidebar-expanded" = false;
        "zen.view.sidebar-expanded.on-hover" = false;
        "zen.view.compact.enable-at-startup" = true;
        "zen.view.compact.should-enable-at-startup" = false;
        "zen.welcome-screen.seen" = true;

        "privacy.sanitize.sanitizeOnShutdown" = true;
        "privacy.history.custom" = true;
        "privacy.clearOnShutdown.offlineApps" = true;
        "privacy.clearOnShutdown_v2.browsingHistoryAndDownloads" = true;
        "privacy.clearOnShutdown_v2.cookiesAndStorage" = true;
        "privacy.clearOnShutdown_v2.cache" = true;
        "privacy.clearOnShutdown_v2.formdata" = true;
      };

    mods = [
      "2e3369c7-e450-46ba-8794-75ccb0de5e48" # Now playing indicator
      "570afd9d-96fa-48b5-bad3-0c106757cce9" # Super Sleek UI
      "58649066-2b6f-4a5b-af6d-c3d21d16fc00" # Private Mode Highlighting
      "5941aefd-67b0-453d-9b62-9071a31cbb0d" # Ultra compact mode
      "6f11c932-b992-433e-8c80-56a613cc511e" # Left close button
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


  # systemd.user.services.niri-flake-polkit.enable = false;

  home.file."Documents/repos/dotfiles".source = dots-repo;

  home.file."Pictures/wallpapers".source = "${dots-repo}/Pictures/wallpapers";

  home.activation.dotsScripts = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p $HOME/Documents
    for script in $HOME/Documents/repos/dotfiles/Documents/executable_*; do
      if [ -f "$script" ]; then
        new_name=$(basename "$script" | sed 's/^executable_//')
        install -m 0755 "$script" "$HOME/Documents/$new_name"
      fi
    done
  '';
}
