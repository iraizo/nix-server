{
  description = "some description ezpz";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs @ { nixpkgs, ... }: {
    nixosConfigurations.nixos-homeserver = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./configuration.nix ./hardware-configuration.nix ];
      specialArgs = { inherit inputs; };
    };
  };
}
