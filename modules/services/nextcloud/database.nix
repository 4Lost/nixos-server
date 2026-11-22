{ ... }:

{
  flake.modules.nixos.nextcloud-database =
    { ... }:

    {
      services.nextcloud = {
        database.createLocally = true;
        config.dbtype = "pgsql";
      };

      services.postgresql = {
        enable = true;
        ensureDatabases = [ "nextcloud" ];
        ensureUsers = [
          {
            name = "nextcloud";
            ensureDBOwnership = true;
          }
        ];
      };
    };
}
