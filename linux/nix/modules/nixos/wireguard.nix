{ config, pkgs, ... }:

let
  tunnelAddress = "10.8.0.2/24";
  peerPublicKey = "gVDgkCGIwLL4XeE2IizzAp3m6uUOaZCJJIzzNaQ3sxI=";
  endpoint = "nas.kaltschm.id:51820";
in
{
  sops.secrets.wg_private.key = "wireguard/private_key";
  sops.secrets.wg_psk.key = "wireguard/preshared_key";

  sops.templates."nas.nmconnection" = {
    content = ''
      [connection]
      id=nas
      type=wireguard
      interface-name=nas
      autoconnect=false

      [wireguard]
      private-key=${config.sops.placeholder.wg_private}

      [wireguard-peer.${peerPublicKey}]
      endpoint=${endpoint}
      allowed-ips=0.0.0.0/0;::/0;
      preshared-key=${config.sops.placeholder.wg_psk}

      [ipv4]
      address1=${tunnelAddress}
      method=manual
      dns=10.0.0.10;
      dns-priority=-50

      [ipv6]
      method=disabled
    '';
    mode = "0600";
    restartUnits = [ "NetworkManager.service" ];
  };

  environment.etc."NetworkManager/system-connections/nas.nmconnection".source =
    config.sops.templates."nas.nmconnection".path;

  systemd.services.NetworkManager.after = [ "sops-install-secrets.service" ];

  environment.systemPackages = [ pkgs.wireguard-tools ];
}
