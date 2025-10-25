{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager.url = github:nix-community/home-manager;
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.fw-nixos = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [ ./hosts/fw-nixos/configuration.nix ];
    };
  };
}
