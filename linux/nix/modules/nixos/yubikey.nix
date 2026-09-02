{ config, pkgs, lib, ... }:

{
  options.sops.age.yubikey = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Whether to use YubiKey for SOPS age decryption";
  };

  config = lib.mkMerge [
    {
      sops.age.yubikey = true;

      services.pcscd.enable = true;
      services.udev.packages = [ pkgs.yubikey-personalization ];

      environment.systemPackages = with pkgs; [
        yubikey-personalization
        yubikey-manager
      ];
    }

    (lib.mkIf config.sops.age.yubikey {
      sops.useSystemdActivation = true;
      sops.age.keyFile = "/var/lib/sops-nix/key.txt";
      sops.age.sshKeyPaths = [];
      sops.age.generateKey = false;
      sops.age.plugins = [ pkgs.age-plugin-yubikey ];

      systemd.services.sops-install-secrets = {
        after = [ "pcscd.service" ];
        wants = [ "pcscd.service" ];
        serviceConfig.ExecStartPre =
          "${pkgs.writeShellScript "gen-yubikey-identity" ''
            if [ ! -s /var/lib/sops-nix/key.txt ]; then
              mkdir -p /var/lib/sops-nix
              ${pkgs.age-plugin-yubikey}/bin/age-plugin-yubikey --identity --slot 1 > /var/lib/sops-nix/key.txt \
                && chmod 600 /var/lib/sops-nix/key.txt \
                || { rm -f /var/lib/sops-nix/key.txt; exit 1; }
            fi
          ''}";
      };

      environment.systemPackages = with pkgs; [
        age-plugin-yubikey
        age
      ];
    })
  ];
}
