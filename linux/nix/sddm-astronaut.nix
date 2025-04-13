{ pkgs, lib, stdenvNoCC, themeConfig ? null, embeddedTheme ? "astronaut" }:
stdenvNoCC.mkDerivation rec {
  pname = "sddm-astronaut";
  version = "1.0";

  src = pkgs.fetchFromGitHub {
    owner = "totoro-ghost";
    repo = "sddm-astronaut";
    rev = "master";
    sha256 = "sha256-j8pJvBml2LWxXNw1e/cSVXV+6w+K1lahv0uK1B9OYn0=";
  };

  dontWrapQtApps = true;

  propagatedBuildInputs = with pkgs.kdePackages; [
    qtsvg
    qtmultimedia
    qtvirtualkeyboard
  ];

  installPhase = ''
    mkdir -p $out/share/sddm/themes/astronaut
    cp -r $src/* $out/share/sddm/themes/astronaut/
  '' + lib.optionalString (themeConfig != null) ''
    # Apply custom theme configuration if provided
    cat > $out/share/sddm/themes/astronaut/theme.conf.user <<EOF
    [General]
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "${name}=${toString value}") themeConfig)}
    EOF
  '';

  meta = {
    description = "Astronaut theme for SDDM";
    homepage = "https://github.com/totoro-ghost/sddm-astronaut";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
  };
}