{ ... }:

{
  flake.modules.nixos.wiki-database =
    { ... }:

    {

      services.wiki-js.settings.db = {
        db = "wiki-js";
        host = "/run/postgresql";
        type = "postgres";
        user = "wiki-js";
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
    };
}
