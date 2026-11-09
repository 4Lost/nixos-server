{
  description = "My NixOS server systems";

  inputs = {
    colmena.url = "github:nix-community/colmena";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { colmena, nixpkgs, ... }: {
    colmenaHive = colmena.lib.makeHive {
      meta = {
        nixpkgs = import nixpkgs {
          system = "x86_64-linux";
          overlays = [ ];
        };
      };
      defaults = import ./host.nix;

      firefly = import ./services/firefly.nix;
      nextcloud = import ./services/nextcloud.nix;
      minecraft = import ./services/minecraft.nix;
      nginx = import ./services/nginx;
    };
  };
}
