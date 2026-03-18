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

  outputs = inputs@{ self, nixpkgs, home-manager, zen-browser, niri, nixvim-config, sops-nix, firefox-addons, dots-repo, dms, quickshell, ... }:
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

    in {
      nixosConfigurations.mk = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
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
            home-manager.extraSpecialArgs = { inherit system zen-browser niri sops-nix firefox-addons dots-repo dms quickshell; };
            home-manager.users.mk = { ... }: {
              imports = [
                ./home.nix
                niri.homeModules.niri
                zen-browser.homeModules.beta
                dms.homeModules.dank-material-shell
                dms.homeModules.niri
              ];
            };
          }
        ];
      };
    };
}
