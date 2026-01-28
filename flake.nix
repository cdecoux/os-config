{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      # Follow corresponding `release` branch from Home Manager
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    alejandra = {
      url = "github:kamadorueda/alejandra/4.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nix.url = "github:cdecoux/neovim-nix";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    alejandra,
    neovim-nix,
    sops-nix,
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
        nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs outputs;};
          inherit system;
          modules = [
            ({ pkgs, modulesPath, ... }: {
            imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];
            environment.systemPackages = [ alejandra.defaultPackage.${system} ];
            })
            ./host/homelab-nix/configuration.nix
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
