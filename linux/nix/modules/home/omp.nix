{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.omp;
  yaml = pkgs.formats.yaml { };
  configFile = yaml.generate "omp-config.yml" cfg.settings;
in
{
  options.programs.omp = {
    enable = lib.mkEnableOption "OMP coding agent";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.llm-agents.omp;
      defaultText = lib.literalExpression "pkgs.llm-agents.omp";
      description = "OMP package to install.";
    };

    settings = lib.mkOption {
      type = lib.types.nullOr yaml.type;
      default = null;
      description = ''
        Settings written declaratively to {file}`~/.omp/agent/config.yml`.
        On each switch the declared settings are copied into place as a
        writable regular file (not a read-only store symlink), so OMP can
        acquire its config lock and rewrite the file when persisting runtime
        changes. Those runtime changes are overwritten by the declared values
        again on the next switch.
      '';
    };
  };

  config = lib.mkMerge [
    { programs.omp.enable = lib.mkDefault true; }
    (lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.activation.ompConfig = lib.mkIf (cfg.settings != null) {
      after = [ "writeBoundary" ];
      data = ''
        run mkdir -p "$HOME/.omp/agent"
        run install -m 600 ${configFile} "$HOME/.omp/agent/config.yml"
      '';
    };

    programs.omp = {
      settings = {
        modelRoles.default = "zai/glm-5.3-flash";
      };
    };

    home.file.".omp/agent/.env".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/ai/keys.env";
    })
  ];
}
