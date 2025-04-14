{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
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
  };

  outputs = { self, nixpkgs, home-manager, zen-browser, ignis, niri, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Create the modified ignis package directly
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
          { nixpkgs.overlays = [ niri.overlays.niri ]; }
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "bck";
            home-manager.users.mk = { ... }: {
              imports = [
                ./home.nix
                niri.homeModules.niri
              ];
              # Pass special arguments to home.nix
              _module.args = {
                inherit system zen-browser niri;
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
