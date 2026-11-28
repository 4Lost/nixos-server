{ inputs, self, ... }:

{
  flake.colmenaHive = inputs.colmena.lib.makeHive {
    meta = {
      nixpkgs = import inputs.nixpkgs {
        system = "x86_64-linux";
        overlays = [ ];
      };
    };

    defaults.imports = with self.modules.nixos; [
      configuration
    ];

    firefly.imports = with self.modules.nixos; [ firefly ];
    home-assistant.imports = with self.modules.nixos; [ home-assistant ];
    nextcloud.imports = with self.modules.nixos; [ nextcloud ];
    minecraft.imports = with self.modules.nixos; [ minecraft ];
    wiki.imports = with self.modules.nixos; [ wiki ];
    nginx.imports = with self.modules.nixos; [ nginx ];
  };
}
