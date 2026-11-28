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
      imports = with self.modules.nixos; [ colmena ];

      systemd.services.wiki-js = {
        requires = [ "postgresql.service" ];
        after = [ "postgresql.service" ];
      };

      services.wiki-js = {
        enable = true;

        settings.db = {
          db = "wiki-js";
          host = "/run/postgresql";
          type = "postgres";
          user = "wiki-js";
        };
      };

      services.postgresql = {
        enable = true;
        ensureDatabases = [ "wiki-js" ];
        ensureUsers = [
          {
            name = "wiki-js";
            ensureDBOwnership = true;
          }
        ];
      };

      sops.secrets = {
        "ssh/private" = {
          owner = "wiki-js";
          group = "wiki-js";
          mode = "0600";
          path = "/etc/wiki/.ssh/id_rsa";
        };

        "ssh/public" = {
          owner = "wiki-js";
          group = "wiki-js";
          mode = "0600";
          path = "/etc/wiki/.ssh/id_rsa.pub";
        };
      };
    };
}
