{ ... }:

{
  flake.modules.nixos.wiki-secrets =
    { ... }:

    {
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
    };
}
