{
  description = "My NixOS server systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      hosts = import ./services.nix;

      mkHost =
        name: host:
        nixpkgs.lib.nixosSystem {
          system = host.system;

          specialArgs = {
            inherit host;
          };

          modules = [
            ./host-settings.nix
            ./services/${name}.nix
          ];
        };
    in
    {
      nixosConfigurations = nixpkgs.lib.mapAttrs mkHost hosts;
    };
}
