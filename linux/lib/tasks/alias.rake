require 'environment'

task :alias do
  add_line_to_file bash_environment, 'alias snip="maim -s | xclip -selection clipboard -t image/png"'
  add_line_to_file fish_environment, 'alias snip="maim -s | xclip -selection clipboard -t image/png"'

  add_line_to_file bash_environment, 'alias yas="yay -S --noconfirm"'
  add_line_to_file fish_environment, 'alias yas="yay -S --noconfirm"'

  add_line_to_file bash_environment, "export fish_env=\"#{fish_environment}\""
  add_line_to_file fish_environment, "export fish_env=\"#{fish_environment}\""

  add_line_to_file bash_environment, "export bash_env=\"#{bash_environment}\""
  add_line_to_file fish_environment, "export bash_env=\"#{bash_environment}\""

add_line_to_file fish_environment, <<-eos
function fish_user_key_bindings
  bind \\cx 'cd ..; commandline -f repaint'
end

fish_user_key_bindings
eos

add_line_to_file fish_environment, <<-eos
function cin
  xrandr --output DP-3 --auto --right-of DVI-D-0
  sleep 2
  xrandr --output DVI-D-0 --brightness .12 && xrandr --output DP-4 --brightness .12
  pacmd set-default-sink alsa_output.pci-0000_01_00.1.hdmi-stereo-extra2

  for SOURCE in (pacmd list-sink-inputs | grep -e 'index:' | cut -d ':' -f2 | xargs)
    pacmd move-sink-input $SOURCE alsa_output.pci-0000_01_00.1.hdmi-stereo-extra2
  end
end
eos

add_line_to_file fish_environment, <<-eos
function idle
  pacmd set-default-sink alsa_output.pci-0000_00_1f.3.analog-stereo
  xrandr --output DP-3 --off
  xrandr --output DVI-D-0 --brightness 1 && xrandr --output DP-4 --brightness 1

  for SOURCE in (pacmd list-sink-inputs | grep -e 'index:' | cut -d ':' -f2 | xargs)
    pacmd move-sink-input $SOURCE alsa_output.pci-0000_00_1f.3.analog-stereo
  end
end
eos

  sh 'source', fish_environment
  sh 'source', bash_environment
end
