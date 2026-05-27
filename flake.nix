{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-26.05";
    nixpkgs-25 = {
      url = "github:NixOS/nixpkgs/release-25.11";
    };
    home-manager = {
      # Follow corresponding `release` branch from Home Manager
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-25 = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-25";
    };
    alejandra = {
      url = "github:kamadorueda/alejandra/4.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nix = {
      url = "github:cdecoux/neovim-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-25,
    home-manager,
    home-manager-25,
    alejandra,
    neovim-nix,
    sops-nix,
    disko,
    ...
  } @ inputs: let
    inherit (self) outputs;
    # Supported systems for your flake packages, shell, etc.
    systems = [
      "x86_64-linux"
    ];
    # This is a function that generates an attribute (genAttrs) by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      fw-nixos = let
        system = "x86_64-linux";
      in
        nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs outputs;};
          inherit system;
          modules = [
            {
              environment.systemPackages = [alejandra.defaultPackage.${system}];
            }
            ./host/fw-nixos/configuration.nix
          ];
        };

      homelab-nix = let
        system = "x86_64-linux";
      in
        nixpkgs-25.lib.nixosSystem {
          specialArgs = {inherit inputs outputs;};
          inherit system;
          modules = [
            disko.nixosModules.disko
            ./host/homelab-nix/configuration.nix
            sops-nix.nixosModules.sops
            home-manager-25.nixosModules.home-manager
            neovim-nix.nixosModule
            {
              nvim.enable = true;
              environment.systemPackages = [alejandra.defaultPackage.${system}];
              home-manager.useUserPackages = true;
              home-manager.users.admin = ./user/homelab/home.nix;
              home-manager.sharedModules = [
                inputs.sops-nix.homeManagerModules.sops
              ];
            }
          ];
        };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      "caleb@fw-nixos" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance

        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          {
            imports = [neovim-nix.homeModule];
            nvim.enable = true;
          }
          ./user/caleb/home.nix
        ];
      };
    };
  };
}
