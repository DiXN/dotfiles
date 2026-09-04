{
  config,
  omp,
  ...
}:

{
  imports = [ omp.homeManagerModules.default ];

  programs.omp = {
    enable = true;
    settings = {
      modelRoles.default = "zai/glm-5.3-flash";
    };
  };

  # omp discovers ~/.omp/agent/.env on its own; symlink it to the shared
  # sops-rendered key store so non-shell launches get keys too.
  home.file.".omp/agent/.env".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/ai/keys.env";
}
