{ config, lib, ... }:

let
  hmUsers = config.home-manager.users;
in
{
  sops.secrets.ai_zai_api_key.key = "ai/zai_api_key";

  # One rendered key store per home-manager user; path and ownership derive
  # from each user's HM and NixOS config — no hardcoded usernames.
  # Consumers:
  #   - zsh sources it (modules/home/shell.nix) so every tool inherits the vars
  #   - omp reads it via ~/.omp/agent/.env symlink (modules/home/omp.nix)
  #   - systemd user units can reference it with EnvironmentFile=
  # Add a provider: new key in secrets.yaml under ai/, plus a secrets entry
  # and one template line here.
  sops.templates = builtins.mapAttrs
    (user: _: {
      content = ''
        ZAI_API_KEY=${config.sops.placeholder.ai_zai_api_key}
      '';
      path = "${hmUsers.${user}.home.homeDirectory}/.config/ai/keys.env";
      owner = user;
      group = config.users.users.${user}.group;
      mode = "0600";
    })
    hmUsers;
}
