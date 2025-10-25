{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      # Follow corresponding `release` branch from Home Manager
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
      self,
      nixpkgs, 
      home-manager, 
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
      fw-nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./hosts/fw-nixos/configuration.nix
        ];
      };
    };

    # nixosConfigurations = {
    #   fw-nixos = nixpkgs.lib.nixosSystem {
    #     system = "x86_64-linux";
    #     specialArgs = { inherit inputs; };
    #     modules = [ 
    #       ./hosts/fw-nixos/configuration.nix
    #       home-manager.nixosModules.home-manager
    #         {
    #           home-manager.useGlobalPkgs = true;
    #           home-manager.useUserPackages = true;
    #           home-manager.users.caleb = ./home/home.nix;

    #           # Optionally, use home-manager.extraSpecialArgs to pass
    #           # arguments to home.nix
    #         }
    #     ];
    #   };
    # }


    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      "caleb@fw-nixos" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./home/home.nix
        ];
      };
    };
  };
}
