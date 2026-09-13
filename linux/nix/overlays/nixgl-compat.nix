{ system, nixGL, dms, quickshell }:
let
  lib = nixGL.inputs.nixpkgs.lib;
  nixglName =
    let v = builtins.getEnv "HM_NIXGL";
    in if v == "" then "nixGLIntel" else v;
  nixglBin = nixGL.packages.${system}.${nixglName};
  wrapBins = name: bins: final: prev:
    prev.symlinkJoin {
      name = "${prev.${name}.name}-nixgl";
      paths = [ prev.${name} ];
      nativeBuildInputs = [ prev.makeWrapper ];
      postBuild = lib.concatMapStrings (b: ''
        if [ -e "$out/bin/${b}" ]; then
          rm "$out/bin/${b}"
          makeWrapper ${nixglBin}/bin/${nixglName} "$out/bin/${b}" --add-flags "${prev.${name}}/bin/${b}"
        fi
      '') bins;
    };
in
final: prev: {
  kitty = wrapBins "kitty" [ "kitty" "kitten" ] final prev;
  wezterm = wrapBins "wezterm" [ "wezterm" "wezterm-gui" "wezterm-mux-server" ] final prev;
  # dms + quickshell come from flakes (not nixpkgs): nixGL binary up front,
  # share/ symlinked, quickshell on PATH so autostart finds `qs`.
  dms-shell-nixgl =
    let
      orig = dms.packages.${system}.dms-shell;
      qsPkg = quickshell.packages.${system}.default;
    in prev.runCommand "dms-shell-nixgl"
      { nativeBuildInputs = [ prev.makeWrapper ]; } ''
      mkdir -p $out/bin
      ln -s ${orig}/share $out/share
      makeWrapper ${nixglBin}/bin/${nixglName} $out/bin/dms \
        --prefix PATH : ${lib.makeBinPath [ qsPkg ]} \
        --set DMS_LOG_FILE /tmp/dms-autostart.log \
        --add-flags "${orig}/bin/dms"
    '';
}
