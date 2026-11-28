{ ... }:

{
  flake.modules.nixos.wiki-backup =
    {
      config,
      domainName,
      pkgs,
      ...
    }:

    let
      backupScript = pkgs.writeShellScript "backup.sh" ''
        #!/usr/bin/env bash

        export PATH="${
          pkgs.lib.makeBinPath [
            pkgs.coreutils
            pkgs.bash
          ]
        }:$PATH"

        sudo systemctl stop wiki-js.service

        mkdir /home/elias/backup

        echo "Database"
        sudo -u postgres pg_dump wiki-js -f "/tmp/database.bak"
        sudo cp /tmp/database.bak /home/elias/backup/database.bak

        sudo systemctl start wiki-js.service

        sudo chown -R elias:users /home/elias/backup
      '';
      importScript = pkgs.writeShellScript "backup.sh" ''
        #!/usr/bin/env bash

        export PATH="${
          pkgs.lib.makeBinPath [
            pkgs.coreutils
            pkgs.bash
          ]
        }:$PATH"

        sudo systemctl stop wiki-js.service

        echo "Database"
        sudo -u postgres dropdb wiki-js
        sudo -u postgres createdb -O wiki-js wiki-js
        sudo -u postgres psql wiki-js < /home/elias/backup/database.bak
        rm -r /home/elias/backup

        sudo systemctl start wiki-js.service
      '';
    in
    {
      systemd.tmpfiles.rules = [
        "L+ /home/elias/backup.sh - - - - ${backupScript}"
        "L+ /home/elias/import.sh - - - - ${importScript}"
      ];
    };
}
