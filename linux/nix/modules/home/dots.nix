{ dots-repo, lib, ... }:

{
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
