{
  description = "NixOS configuration";

  nixConfig = {
    extra-substituters = [
      "https://niri.cachix.org"
    ];
    extra-trusted-public-keys = [
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      # IMPORTANT: we're using "libgbm" and is only available in unstable so ensure
      # to have it up to date or simply don't specify the nixpkgs input
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim-config = {
      url = "github:mkalts/nixvim-config";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dots-repo = {
      url = "github:dixn/dotfiles/chezmoi";
      flake = false;
    };
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell = {
      url = "git+https://git.outfoxxed.me/quickshell/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, zen-browser, niri, nixvim-config, sops-nix, disko, firefox-addons, dots-repo, dms, quickshell, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      vmScript = pkgs.writeShellScript "nixos-test-vm" ''
        set -euo pipefail
        IMG="''${1:-mk.qcow2}"
        if [ ! -f "$IMG" ]; then
          echo "$IMG not found - build it first: nix run .#image"
          exit 1
        fi
        VARS="$(mktemp -d)/VARS.fd"
        install -m 600 ${pkgs.OVMF.variables} "$VARS"
        USB=()
        if [ "''${YUBIKEY:-0}" = "1" ]; then
          entry=$(${pkgs.usbutils}/bin/lsusb | grep -m1 'ID 1050:')
          bus=$(echo "$entry" | awk '{print $2}')
          dev=$(echo "$entry" | awk '{print $4}' | tr -d ':')
          USB=(-device usb-host,bus=xhci.0,hostbus="$bus",hostaddr="$dev")
        fi
        if [ -n "''${WAYLAND_DISPLAY:-}" ] && [ "''${SDLDRIVER:-wayland}" = "wayland" ]; then
          export SDL_VIDEODRIVER=wayland
        fi
        if [ "''${SDL:-0}" = "1" ]; then
          DISP=(-display sdl,gl=on)
        else
          DISP=(-display gtk,gl=on,grab-on-hover=on)
        fi
        if [ "''${VENUS:-1}" = "1" ]; then
          GPU=(-device virtio-vga-gl,hostmem=8G,venus=true,blob=true)
        else
          GPU=(-device virtio-vga-gl)
        fi
        export GBM_BACKENDS_PATH="${pkgs.mesa}/lib/gbm"
        export LIBGL_DRIVERS_PATH="${pkgs.mesa}/lib/dri"
        export __EGL_VENDOR_LIBRARY_FILENAMES="${pkgs.mesa}/share/glvnd/egl_vendor.d/50_mesa.json"
        exec ${pkgs.qemu}/bin/qemu-system-x86_64 \
          -enable-kvm -cpu host -smp 8 -m 8G \
          -device virtio-rng-pci \
          -device qemu-xhci,id=xhci \
          "''${DISP[@]}" \
          "''${GPU[@]}" \
          -drive if=pflash,format=raw,readonly=on,file=${pkgs.OVMF.firmware} \
          -drive if=pflash,format=raw,file="$VARS" \
          -drive if=virtio,format=qcow2,file="$IMG" \
          -device virtio-net-pci,netdev=net0 -netdev user,id=net0,hostfwd=tcp::2222-:22 \
          -audiodev pipewire,id=snd0 -device intel-hda -device hda-output,audiodev=snd0 \
          "''${USB[@]}"
      '';

      mgmtScript = pkgs.writeShellScript "nixos-mk" ''
        set -euo pipefail
        FLAKE=/tmp/dotfiles/linux/nix
        TARGET="''${TARGET:-mk}"
        export NIX_CONFIG="accept-flake-config = true"
        VM_DIR=/mnt/x/vm
        export NIX_SSHOPTS="-p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PubkeyAuthentication=no -o PreferredAuthentications=password"
        case "''${1:-help}" in
          image)
            cd "$VM_DIR"
            rm -f mk.raw mk.qcow2
            script=$(${pkgs.nix}/bin/nix build --print-out-paths --no-link \
              "$FLAKE#nixosConfigurations.$TARGET.config.system.build.diskoImagesScript")
            exec "$script"
            ;;
          vm)
            cd "$VM_DIR"
            exec ${vmScript}
            ;;
          switch|test|boot)
            exec ${pkgs.sshpass}/bin/sshpass -p mk \
              ${pkgs.nixos-rebuild}/bin/nixos-rebuild "$1" --flake "$FLAKE#$TARGET" \
              --target-host mk@localhost --use-remote-sudo
            ;;
          install)
            dev=''${2:?usage: nix run .# -- install /dev/sdX}
            [ -b "$dev" ] || { echo "not a block device: $dev"; exit 1; }
            echo "WILL DESTROY ALL DATA on $dev"
            read -rp "type $(basename "$dev") to confirm: " a
            [ "$a" = "$(basename "$dev")" ] || exit 1
            sudo ${disko.packages.${system}.disko}/bin/disko --mode disko "$FLAKE/disko-config.nix" --argstr targetDisk "$dev" --arg withSwap true --argstr filesystem btrfs
            sudo env NIX_CONFIG="accept-flake-config = true" TMPDIR=/mnt ${pkgs.nixos-install}/bin/nixos-install --flake "$FLAKE#$TARGET" --no-root-password
            ;;
          usb)
            dev=''${2:?usage: nix run .# -- usb /dev/sdX}
            [ -b "$dev" ] || { echo "not a block device: $dev"; exit 1; }
            img="$VM_DIR/mk.qcow2"
            [ -f "$img" ] || img="$VM_DIR/mk.raw"
            [ -f "$img" ] || { echo "no image - run: nix run .# -- image"; exit 1; }
            need=$(${pkgs.qemu}/bin/qemu-img info --output=json "$img" | ${pkgs.jq}/bin/jq -r '."virtual-size"')
            have=$(lsblk -b -n -o SIZE "$dev")
            [ "$have" -ge "$need" ] || { echo "stick too small: $(numfmt --to=iec "$have") < $(numfmt --to=iec "$need")"; exit 1; }
            echo "WILL OVERWRITE $dev ($(numfmt --to=iec "$have")) with $img (virtual $(numfmt --to=iec "$need"))"
            read -rp "type $(basename "$dev") to confirm: " a
            sudo ${pkgs.qemu}/bin/qemu-img convert -O raw "$img" "$dev"
            ;;
          clean)
            pkill -9 -f 'qemu-system-x86_64.*mk\.(raw|qcow2)' || true
            rm -f "$VM_DIR"/VARS.fd "$VM_DIR"/qemu-*.pid
            echo cleaned
            ;;
          *)
            cat <<'USAGE'
usage: nix run .# -- <command>
  image            rebuild pristine mk.qcow2 (wipes the VM disk)
  vm               boot the VM (prefix YUBIKEY=1 for key passthrough)
  switch|test|boot fast rebuild into the running VM (test = reboot reverts)
  install <dev>    disko-format + nixos-install onto a device
  usb <dev>        write the image onto a device (raw convert; >= 24G)
  clean            kill stray qemu, remove VARS/pid files

TARGET=<name> selects targets/<name>.nix (default: mk)
USAGE
            ;;
        esac
      '';

      mkHost = { name, imageSize ? "100G" }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./targets/${name}.nix
            sops-nix.nixosModules.sops
            disko.nixosModules.disko
            {
              disko.devices.disk.my-disk.imageName = name;
              disko.devices.disk.my-disk.imageSize = imageSize;
            }
            {
              nixpkgs.overlays = [
                niri.overlays.niri
                firefox-addons.overlays.default
                (final: prev: {
                  nixvim = nixvim-config.packages.${system}.default;
                })

                (final: prev: {
                  aggregateModules = modules: let
                    agg = prev.aggregateModules modules;
                    kernel = builtins.head modules;
                  in
                    if kernel ? target then agg // { inherit (kernel) target; } else agg;
                })
              ];
            }
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "bck";
              home-manager.extraSpecialArgs = { inherit system zen-browser niri sops-nix firefox-addons dots-repo dms quickshell; };
              home-manager.users.mk.imports = [
                ./modules/home/common.nix
              ];
            }
          ];
        };

    in {
      nixosConfigurations.mk = mkHost { name = "mk"; };
      nixosConfigurations.notebook = mkHost { name = "notebook"; };

      apps.${system} = {
        default = { type = "app"; program = "${mgmtScript}"; };
        disko = { type = "app"; program = "${disko.packages.${system}.disko}/bin/disko"; };
        image = { type = "app"; program = toString (pkgs.writeShellScript "image" ''exec ${mgmtScript} image''); };
        test-vm = { type = "app"; program = toString (pkgs.writeShellScript "test-vm" ''exec ${mgmtScript} vm''); };
        vm-switch = { type = "app"; program = toString (pkgs.writeShellScript "vm-switch" ''exec ${mgmtScript} ''${1:-test}''); };
      };
    };
}
