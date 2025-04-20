{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      # IMPORTANT: we're using "libgbm" and is only available in unstable so ensure
      # to have it up to date or simply don't specify the nixpkgs input
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ignis = {
      url = "github:linkfrg/ignis";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim-config = {
      url = "github:mkalts/nixvim-config";
    };
  };

  outputs = { self, nixpkgs, home-manager, zen-browser, ignis, niri, nixvim-config, sops-nix, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      ageKeyModule = { config, lib, ... }: {
        options = {
          sops.age.yubikey = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether to use YubiKey for SOPS age decryption";
          };
        };

        config = lib.mkIf config.sops.age.yubikey {
          system.activationScripts = {
            ageSopsSetup = {
              deps = [ "specialfs" ];
              text = ''
                mkdir -p /var/lib/sops-nix
                ${pkgs.age-plugin-yubikey}/bin/age-plugin-yubikey --identity --slot 1 > /var/lib/sops-nix/key.txt
                chmod 600 /var/lib/sops-nix/key.txt

                export PATH="${pkgs.age-plugin-yubikey}/bin:$PATH"
              '';
            };
          };

          sops.age.keyFile = "/var/lib/sops-nix/key.txt";
          sops.age.sshKeyPaths = [];
          sops.age.generateKey = false;

          environment.systemPackages = with pkgs; [
            age-plugin-yubikey
            age
          ];

          services.pcscd.enable = true;
        };
      };

      ignisWithDeps = ignis.packages.${system}.ignis.overrideAttrs (oldAttrs: {
        propagatedBuildInputs = (oldAttrs.propagatedBuildInputs or []) ++ (with pkgs; [
          (python312.withPackages (ppkgs: [
            ppkgs.materialyoucolor
            ppkgs.pillow
            ppkgs.jinja2
          ]))
        ]);
      });
    in {
      nixosConfigurations.mk = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          sops-nix.nixosModules.sops
          ageKeyModule
          { nixpkgs.overlays = [
              niri.overlays.niri
              (final: prev: {
                nixvim = nixvim-config.packages.${system}.default;
              })
            ];

            sops.age.yubikey = true;
          }
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "bck";
            home-manager.users.mk = { ... }: {
              imports = [
                ./home.nix
                niri.homeModules.niri
              ];
              _module.args = {
                inherit system zen-browser niri;
                inherit sops-nix;
                ignis = {
                  packages.${system} = {
                    default = ignisWithDeps;
                    ignis = ignisWithDeps;
                  };
                };
              };
            };
          }
        ];
      };
    };
}
