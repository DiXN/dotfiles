{ config, pkgs, lib, ... }:

{
  home.username = "mk";
  home.homeDirectory = "/home/mk";

  # Dotfiles management with home-manager instead of chezmoi
  home.file = {
    ".config/git/config".text = ''
      [user]
        name = Michael Kaltschmid
        email = kaltschmidmichael@gmail.com
    '';

    # Pictures integration - fetch wallpapers from Git repository without hash
    "Pictures/wallpapers".source = builtins.fetchGit {
      url = "https://github.com/DiXN/dotfiles.git";
      ref = "chezmoi"; # Using the chezmoi branch
      submodules = false;
    } + "/Pictures/wallpapers";

    # Documents integration with executable scripts
    "Documents".source = let
      repo = builtins.fetchGit {
        url = "https://github.com/DiXN/dotfiles.git";
        ref = "chezmoi";
      };

      # Process the Documents directory to make executable files executable
      processedDocs = pkgs.runCommand "processed-documents" {} ''
        mkdir -p $out
        cp -r ${repo}/Documents/* $out/

        # Make executable_* files executable and rename them
        for file in $out/executable_*; do
          if [ -f "$file" ]; then
            chmod +x "$file"
            mv "$file" "''${file/executable_/}"
          fi
        done
      '';
    in processedDocs;
  };

  # Zsh configuration
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    history = {
      path = "${config.xdg.configHome}/zsh/.zsh_history";
      size = 10000;
      save = 10000;
      ignoreDups = true;
      share = true;
    };
    shellAliases = {
      ec = "$EDITOR $XDG_CONFIG_HOME/zsh/.zshrc";
      sc = "source $XDG_CONFIG_HOME/zsh/.zshrc";
      yas = "yay -S --noconfirm";
      ze = "z -e";
      yar = "yay -Rcns";
      ads = "~/Documents/androidshare.sh";
      bd = "~/Documents/brightness.sh down";
      bu = "~/Documents/brightness.sh up";
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
        bash "/home/$USER/Documents/spell.sh $1"
      }

      # Vulkan setup
      export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json

      VULKAN_SDK="/home/$USER/.local/share/vulkan/x86_64"
      export VULKAN_SDK
      export PATH="$VULKAN_SDK/bin:$PATH"
      export LD_LIBRARY_PATH=$VULKAN_SDK/lib
      export VK_LAYER_PATH=$VULKAN_SDK/etc/vulkan/explicit_layer.d

      # Dotfiles
      export DOTFILES_ROOT="$HOME/Documents/repos/dotfiles"

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
      [[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh
    '';
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.7.0";
          sha256 = "KLUYpUu4DHRumQZ3w59m9aTW6TBKMCXl2UcKi4uMd7w=";
        };
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "0.7.1";
          sha256 = "gOG0NLlaJfotJfs+SUhGgLTNOnGLjoqnUp54V9aFJg8=";
        };
      }
    ];
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
}
