{ modulesPath, lib, pkgs, inputs, ... }:

{
  imports = [
    "${modulesPath}/virtualisation/lxc-container.nix"
  ];

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

  networking.networkmanager.enable = lib.mkForce false;

  services.displayManager.dms-greeter.enable = lib.mkDefault true;
  services.greetd.settings.terminal.vt = lib.mkForce 12;

  services.syncthing.enable = lib.mkForce false;
  services.openssh.enable = lib.mkForce false;

  home-manager.users.mk.programs.omp.enable = lib.mkForce false;

  nix.gc.automatic = lib.mkForce false;

  systemd.services.nix-daemon.enable = lib.mkForce false;
  systemd.sockets.nix-daemon.enable = lib.mkForce false;
  systemd.services.nix-channel-init.enable = lib.mkForce false;

  sops.secrets = lib.mkForce { };
  sops.templates = lib.mkForce { };

  services.udev.enable = lib.mkForce true;
  services.udev.extraRules = ''
    SUBSYSTEM=="drm", KERNEL=="card[0-9]*|renderD[0-9]*", TAG+="seat"
    SUBSYSTEM=="drm", KERNEL=="card[0-9]*", TAG+="master-of-seat"
    SUBSYSTEM=="input", KERNEL=="event[0-9]*", TAG+="seat"
  '';

  environment.sessionVariables = {
    PIPEWIRE_RUNTIME_DIR = "/run/pw-host";
    PULSE_SERVER = "unix:/run/pw-host/pulse/native";
  };

  services.pipewire.enable = lib.mkForce false;
  services.pipewire.wireplumber.enable = lib.mkForce false;

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "bluetoothctl" ''
      exec env DBUS_SYSTEM_BUS_ADDRESS=unix:path=/run/host/system_bus_socket \
        ${pkgs.bluez}/bin/bluetoothctl "$@"
    '')
  ];

  home-manager.users.mk.programs.dank-material-shell.package =
    let
      orig = inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.dms-shell;
    in
    pkgs.symlinkJoin {
      name = "${orig.name}-host-bus";
      paths = [ orig ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        rm $out/bin/dms
        makeWrapper ${orig}/bin/dms $out/bin/dms \
          --set DBUS_SYSTEM_BUS_ADDRESS unix:path=/run/host/system_bus_socket
      '';
    };

  systemd.services.input-seat-retag = {
    description = "retag input devices so libinput sees them (udevd netlink broadcast is blocked in containers)";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-udev.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/udevadm trigger --subsystem-match=input --action=change";
    };
  };
}
