{
  description = "Hyprland on Nixos";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia-qs = {
      url = "github:noctalia-dev/noctalia-qs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake/beta";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    betterfox = {
      url = "github:yokoffing/Betterfox";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-stable, home-manager, lanzaboote, ... }:
    let
      system = "x86_64-linux";
      # Initialize the stable package set
      pkgs-stable = import nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.nixos-btw = nixpkgs.lib.nixosSystem {
        inherit system;
        # Add pkgs-stable to specialArgs for system modules
        specialArgs = { inherit inputs pkgs-stable; };
        modules = [
          ./configuration.nix
          ./lanzaboote.nix
          ./virtualization.nix
          ./desktop-services.nix
          ./sound.nix
          ./udev-rules.nix
          ./modules/thunar.nix
          #          ./llm.nix
          {
            nixpkgs.overlays = [
              (import ./overlays/openldap.nix { lib = nixpkgs.lib; })
            ];
          }
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              # Add pkgs-stable here if you need it in home.nix
              extraSpecialArgs = { inherit inputs pkgs-stable; };
              users.goku = import ./home.nix;
              backupFileExtension = "backup";
            };
          }
        ];
      };
    };
}

