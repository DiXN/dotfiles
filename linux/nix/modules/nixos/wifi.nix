{ config, lib, ... }:

let
  networks = {
    "dlink-BA94" = { };
  };
in
{
  sops.secrets = builtins.mapAttrs (ssid: _: {
    key = "wifi/${ssid}";
  }) networks;

  sops.templates = builtins.mapAttrs (ssid: _: {
    content = ''
      [connection]
      id=${ssid}
      type=wifi
      autoconnect=true

      [wifi]
      mode=infrastructure
      ssid=${ssid}

      [wifi-security]
      key-mgmt=wpa-psk
      psk=${config.sops.placeholder."${ssid}"}

      [ipv4]
      method=auto

      [ipv6]
      method=auto
    '';
    mode = "0600";
    restartUnits = [ "NetworkManager.service" ];
  }) networks;

  systemd.services.NetworkManager.after = [ "sops-install-secrets.service" ];

  environment.etc = builtins.listToAttrs (map (ssid: {
    name = "NetworkManager/system-connections/${ssid}.nmconnection";
    value = { source = config.sops.templates.${ssid}.path; };
  }) (builtins.attrNames networks));
}
