{
  description = "NixOS configuration";

  nixConfig = {
    extra-substituters = [
      "https://niri.cachix.org"
      "https://nix-community.cachix.org"
      "https://cache.numtide.com"
    ];
    extra-trusted-public-keys = [
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    # Foreign-distro GL compat (nixGL). Only consumed by homeConfigurations.foreign.
    nixGL = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, zen-browser, niri, nixvim-config, sops-nix, disko, firefox-addons, dots-repo, dms, quickshell, nixGL, llm-agents, ... }:
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
        MACH=/var/lib/machines/mk-nix-sys
        GCROOT="$HOME/.cache/mk-nix-sys-toplevel"
        do_import() {
          mkdir -p "$(dirname "$GCROOT")"
          TOPLEVEL=$(${pkgs.nix}/bin/nix build --print-out-paths --out-link "$GCROOT" "$FLAKE#nixosConfigurations.nspawn.config.system.build.toplevel")
          sudo machinectl terminate mk-nix-sys 2>/dev/null || true
          sudo rm -rf "$MACH"
          sudo mkdir -p "$MACH"/sbin "$MACH"/etc "$MACH"/proc "$MACH"/sys "$MACH"/dev
          sudo chmod 755 /var/lib/machines
          sudo ln -sfn "$TOPLEVEL/init" "$MACH/sbin/init"
          sudo cp -f "$TOPLEVEL/etc/os-release" "$MACH/etc/os-release"
          echo "mk-nix-sys skeleton -> $TOPLEVEL (pinned at $GCROOT, store shared ro at boot)"
        }
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
          foreign)
            # Bootstrap a foreign-distro (Arch) user for homeConfigurations.foreign.
            # HM_USER=mk selects the user (default: mk-nix). Idempotent.
            FUSER="''${HM_USER:-mk-nix}"
            sudo pacman -S --needed --noconfirm nix
            sudo systemctl enable --now nix-daemon.service
            sudo mkdir -p /etc/nix
            grep -q "experimental-features" /etc/nix/nix.conf 2>/dev/null \
              || echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf >/dev/null
            RESTART=no
            if grep -q "^trusted-users" /etc/nix/nix.conf 2>/dev/null; then
              if ! grep -q "^trusted-users.*$FUSER" /etc/nix/nix.conf; then
                sudo sed -i "s/^trusted-users.*/& $FUSER/" /etc/nix/nix.conf
                RESTART=yes
              fi
            else
              echo "trusted-users = root $FUSER" | sudo tee -a /etc/nix/nix.conf >/dev/null
              RESTART=yes
            fi
            [ "$RESTART" = yes ] && sudo systemctl restart nix-daemon.service
            id "$FUSER" &>/dev/null || sudo useradd -m "$FUSER"
            sudo loginctl enable-linger "$FUSER" || true
            sudo -u "$FUSER" sh -c 'grep -qs "hm-session-vars" ~/.profile || printf "%s\n" "" "# nix home-manager session env" "if [ -f \"\$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh\" ]; then" "  . \"\$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh\"" "fi" >> ~/.profile'
            NIXGL="''${HM_NIXGL:-}"
            if [ -z "$NIXGL" ]; then
              NIXGL=nixGLIntel
              ${pkgs.pciutils}/bin/lspci 2>/dev/null | grep -qi nvidia && NIXGL=nixGLNvidia
            fi
            sudo -u "$FUSER" -i env \
              HM_USER="$FUSER" HM_NIXGL="$NIXGL" NIX_CONFIG="accept-flake-config = true" \
              ${pkgs.nix}/bin/nix run github:nix-community/home-manager/master -- switch \
              --impure --flake "path:$FLAKE#foreign" -b backup
            ZSHBIN="/home/$FUSER/.nix-profile/bin/zsh"
            if [ -x "$ZSHBIN" ]; then
              grep -qs "$ZSHBIN" /etc/shells || echo "$ZSHBIN" | sudo tee -a /etc/shells >/dev/null
              sudo chsh -s "$ZSHBIN" "$FUSER"
            fi
            echo "done: $FUSER bootstrapped from $FLAKE#foreign"
            ;;
          nspawn-import)
            do_import
            ;;
          nspawn)
            imported=0
            if [ "''${REBUILD:-0}" = 1 ] || [ ! -L "$MACH/sbin/init" ] || [ ! -e "$GCROOT" ]; then
              do_import
              imported=1
            else
              TOPLEVEL=$(readlink "$MACH/sbin/init"); TOPLEVEL="''${TOPLEVEL%/init}"
              if [ ! -e "$TOPLEVEL/init" ]; then
                do_import
                imported=1
              fi
            fi
            [ "$imported" = 1 ] || [ -d "$MACH" ] || { echo "no machine - run: nix run .# -- nspawn-import"; exit 1; }
            command -v systemd-nspawn >/dev/null || { echo "missing systemd-nspawn (systemd-container)"; exit 1; }
            CHOME=/home/mk # guest home, must match users.users.mk.home in targets/nspawn.nix
            # bind ro|rw <host-path> [guest-path]: append unless the host path is missing.
            # Returns 1 when skipped - always guard it (set -e): `bind ... || true`, `if bind ...`.
            bind() {
              local dst="''${3:-$2}"
              [ -e "$2" ] || return 1
              if [ "$1" = ro ]; then BINDS+=(--bind-ro="$2:$dst"); else BINDS+=(--bind="$2:$dst"); fi
            }
            # hbind ro|rw <path-under-$HOME>: share ~/<path> into the guest's home, skip when absent.
            hbind() { bind "$1" "$HOME/$2" "$CHOME/$2"; }
            # --- base: store, GPU/input, boot ttys, shm (required, nspawn fails when missing) ---
            BINDS=(--bind-ro=/nix --bind=/dev/dri --bind=/dev/input --bind=/dev/tty0 --bind=/dev/tty12)
            BINDS+=(--bind=/dev/shm)
            # --- audio + host dbus (required, remapped into the guest) ---
            BINDS+=(--bind-ro=/run/user/1000/pipewire-0:/run/pw-host/pipewire-0 --bind-ro=/run/user/1000/pulse:/run/pw-host/pulse)
            BINDS+=(--bind-ro=/run/dbus/system_bus_socket:/run/host/system_bus_socket)
            PROPS=(--property=DeviceAllow=char-drm --property=DeviceAllow=char-input
                   --capability=CAP_SYS_TTY_CONFIG --capability=CAP_NET_ADMIN --capability=CAP_IPC_LOCK
                   --system-call-filter=sendmsg --system-call-filter=recvmsg)
            # --- YubiKey CCID: share host pcscd socket (slot needs no PIN/touch) ---
            bind rw /run/pcscd/pcscd.comm || echo "no host pcscd socket - YubiKey/sops unavailable in container" >&2
            if ! ${pkgs.usbutils}/bin/lsusb 2>/dev/null | grep -q 'ID 1050:'; then
              echo "no YubiKey on host USB - sops secrets will fail to decrypt" >&2
            fi
            # --- YubiKey HID (OTP/FIDO): stable by-id nodes, resolved at launch ---
            seen=""
            for h in /dev/input/by-id/usb-Yubico_YubiKey*-hidraw /dev/input/by-id/usb-Yubico_YubiKey*-fido; do
              [ -e "$h" ] || continue
              node=$(readlink -f "$h")
              case " $seen " in *" $node "*) continue;; esac
              seen="$seen $node"
              bind rw "$node" || continue
              PROPS+=(--property="DeviceAllow=$node rwm")
            done
            # --- bulk media mounts (same path, skipped when absent) ---
            for m in /mnt/q /mnt/x; do bind rw "$m" || true; done
            # --- gaming: wine prefixes (rw, guest sees the same ~/ layout) ---
            for p in .wine .proton .winef3 Games; do hbind rw "$p" || true; done
            # --- gaming: launcher data (game lists, custom runners) ---
            for p in .local/share/faugus-launcher .local/share/Steam/compatibilitytools.d \
                     .local/share/pluto .local/share/lutris .local/share/rockstar-games-launcher; do
              hbind rw "$p" || true
            done
            SROOT=$HOME/.local/share/Steam
            case "''${STEAM:-rw-client}" in
              ro-games) # fresh login every boot, game payloads ro
                if hbind ro .local/share/Steam/steamapps/common; then
                  hbind ro .local/share/Steam/libraryfolders.vdf || true
                  for m in "$SROOT"/steamapps/*.acf; do
                    [ -f "$m" ] || continue
                    BINDS+=(--bind-ro="$m:$CHOME/.local/share/Steam/steamapps/$(basename "$m")")
                  done
                else
                  echo "no host Steam library found - starting isolated" >&2
                fi
                ;;
              rw-client) # login persists, game payloads stay ro
                if hbind rw .local/share/Steam; then
                  hbind ro .local/share/Steam/steamapps/common || true
                else
                  echo "no host Steam dir found - starting isolated" >&2
                fi
                ;;
              full) # whole Steam tree rw - can overwrite your install
                hbind rw .local/share/Steam || echo "no host Steam dir found - starting isolated" >&2
                ;;
            esac
            exec sudo SYSTEMD_NSPAWN_API_VFS_WRITABLE=1 systemd-nspawn --machine=mk-nix-sys -bD "$MACH" --ephemeral "''${BINDS[@]}" "''${PROPS[@]}"
            ;;
          nspawn-shell)
            exec sudo machinectl shell mk-nix-sys
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
  nspawn-import    rebuild nspawn skeleton mk-nix-sys (shares host /nix, no copy)
  nspawn           boot mk-nix-sys ephemeral with GPU + display/audio passthrough
                   (auto-imports when missing/stale, REBUILD=1 forces;
                   STEAM=isolated|ro-games|rw-client|full, default rw-client)
  nspawn-shell     open shell in running mk-nix-sys
  foreign          bootstrap foreign-distro user for homeConfigurations.foreign
                   (HM_USER=mk selects user, default mk-nix; HM_NIXGL overrides GPU detect)
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
                llm-agents.overlays.shared-nixpkgs
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

      mkContainer = { name }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./targets/${name}.nix
            sops-nix.nixosModules.sops
            {
              nixpkgs.overlays = [
                niri.overlays.niri
                firefox-addons.overlays.default
                llm-agents.overlays.shared-nixpkgs
                (final: prev: {
                  nixvim = nixvim-config.packages.${system}.default;
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
      nixosConfigurations.nspawn = mkContainer { name = "nspawn"; };

      # Standalone home-manager for foreign distros (e.g. Arch). The NixOS
      # hosts above do NOT evaluate any of this.
      # Default user is mk-nix; override with HM_USER (needs --impure):
      #   HM_USER=mk home-manager switch --impure --flake .#foreign
      # Nvidia instead of Intel: HM_NIXGL=nixGLNvidia (also needs --impure).
      homeConfigurations.foreign =
        let
          foreignUser =
            let u = builtins.getEnv "HM_USER";
            in if u == "" then "mk-nix" else u;
        in home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              niri.overlays.niri
              (final: prev: {
                nixvim = nixvim-config.packages.${system}.default;
              })
              (import ./overlays/nixgl-compat.nix { inherit system nixGL dms quickshell; })
            ];
          };
          extraSpecialArgs = { inherit system niri dms quickshell; };
          modules = [
            {
              home.username = foreignUser;
              home.homeDirectory = "/home/${foreignUser}";
              home.stateVersion = "26.05";
              programs.home-manager.enable = true;
            }
            ./modules/home/niri.nix
            ./modules/home/shell.nix
            ./modules/home/terminals.nix
            ./modules/home/dms.nix
            ({ pkgs, ... }: {
              programs.dank-material-shell.package = pkgs.dms-shell-nixgl;
            })
          ];
        };

      apps.${system} = {
        default = { type = "app"; program = "${mgmtScript}"; };
        disko = { type = "app"; program = "${disko.packages.${system}.disko}/bin/disko"; };
        image = { type = "app"; program = toString (pkgs.writeShellScript "image" ''exec ${mgmtScript} image''); };
        test-vm = { type = "app"; program = toString (pkgs.writeShellScript "test-vm" ''exec ${mgmtScript} vm''); };
        vm-switch = { type = "app"; program = toString (pkgs.writeShellScript "vm-switch" ''exec ${mgmtScript} ''${1:-test}''); };
      };
    };
}
