{
  description = "some description ezpz";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { nixpkgs, ... }: {
    nixosConfigurations.nixos-homeserver = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
      	./configuration.nix
	./hardware-configuration.nix
	inputs.home-manager.nixosModules.home-manager {
		home-manager.useGlobalPkgs = true;
		home-manager.useUserPackages = true;
		home-manager.users.raizo = import ./home.nix;
		home-manager.extraSpecialArgs=  {inherit inputs;};
	  }
	];
      specialArgs = { inherit inputs; };
    };
  };
}
