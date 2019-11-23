require 'environment'

task :alias do
  add_line_to_file bash_environment, 'alias snip="maim -s | xclip -selection clipboard -t image/png"'
  add_line_to_file fish_environment, 'alias snip="maim -s | xclip -selection clipboard -t image/png"'

  add_line_to_file bash_environment, 'alias yas="yay -S --noconfirm"'
  add_line_to_file fish_environment, 'alias yas="yay -S --noconfirm"'

  add_line_to_file bash_environment, 'alias ze="z -e"'
  add_line_to_file fish_environment, 'alias ze="z -e"'

  add_line_to_file bash_environment, 'export BAT_THEME="GitHub"'
  add_line_to_file fish_environment, 'export BAT_THEME="GitHub"'

  add_line_to_file bash_environment, "export fish_env=\"#{fish_environment}\""
  add_line_to_file fish_environment, "export fish_env=\"#{fish_environment}\""

  add_line_to_file bash_environment, "export bash_env=\"#{bash_environment}\""
  add_line_to_file fish_environment, "export bash_env=\"#{bash_environment}\""

  add_line_to_file fish_environment, 'alias yar="yay -Rcns"'
  add_line_to_file bash_environment, 'alias yar="yay -Rcns"'

  add_line_to_file fish_environment, <<~eos
    function fish_user_key_bindings
      bind \\cx 'cd ..; commandline -f repaint'
    end

    fish_user_key_bindings
  eos

  add_line_to_file fish_environment, <<~eos
    function cin
      xrandr --output DP-3 --auto --right-of DVI-D-0
      sleep 2
      xrandr --output DVI-D-0 --brightness .12 && xrandr --output DP-4 --brightness .12
      pacmd set-default-sink (pacmd list-sinks | grep 'extra' | head -n 1 | cut -d '<' -f2 | cut -d '>' -f1)

      for SOURCE in (pacmd list-sink-inputs | grep -e 'index:' | cut -d ':' -f2 | xargs)
        pacmd move-sink-input $SOURCE (pacmd list-sinks | grep 'extra' | head -n 1 | cut -d '<' -f2 | cut -d '>' -f1)
      end
    end
  eos

  add_line_to_file fish_environment, <<~eos
    function idle
      pacmd set-default-sink alsa_output.pci-0000_00_1f.3.analog-stereo
      xrandr --output DP-3 --off
      xrandr --output DVI-D-0 --brightness 1 && xrandr --output DP-4 --brightness 1

      for SOURCE in (pacmd list-sink-inputs | grep -e 'index:' | cut -d ':' -f2 | xargs)
        pacmd move-sink-input $SOURCE alsa_output.pci-0000_00_1f.3.analog-stereo
      end
    end
  eos

  add_line_to_file fish_environment, <<~eos
    function full
      xrandr --output DP-3 --auto --right-of DVI-D-0
    end
  eos

  add_line_to_file fish_environment, <<~eos
    if not functions -q fisher
      set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
      curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
      fish -c fisher
    end
  eos

  add_line_to_file '~/.vimrc', <<~eos
    set clipboard=unnamed
    filetype plugin indent on
    set expandtab
    
    set tabstop=2
    set softtabstop=2
    set shiftwidth=2
    
    syntax on
  eos
end
