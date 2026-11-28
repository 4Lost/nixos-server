{ self, ... }:

{
  flake.modules.nixos.wiki =
    {
      config,
      domainName,
      pkgs,
      ...
    }:

    let
      host = {
        name = "home";
        address = "home.${domainName}";
        ip = "192.168.0.204";
        port = 22;
        firewall = [
          3000
        ];
      };
    in
    {
      networking.enableIPv6 = true;

      _module.args.host = host;
      imports = with self.modules.nixos; [
        colmena
        wiki-backup
        wiki-database
        wiki-secrets
      ];

      systemd.services.wiki-js = {
        requires = [ "postgresql.service" ];
        after = [ "postgresql.service" ];
      };

      services.wiki-js.enable = true;
    };
}
