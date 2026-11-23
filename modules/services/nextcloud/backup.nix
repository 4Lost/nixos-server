{ ... }:

{
  flake.modules.nixos.nextcloud-backup =
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
            config.services.nextcloud.occ
          ]
        }:$PATH"

        nextcloud-occ maintenance:mode --on

        mkdir /home/elias/backup
        cp -r /var/lib/nextcloud/data /home/elias/backup/data
        sudo -u postgres pg_dump nextcloud -f "/tmp/database.bak"
        cp /tmp/database.bak /home/elias/backup/database.bak

        nextcloud-occ maintenance:mode --off
      '';
      importScript = pkgs.writeShellScript "backup.sh" ''
        #!/usr/bin/env bash

        export PATH="${
          pkgs.lib.makeBinPath [
            pkgs.coreutils
            pkgs.bash
            config.services.nextcloud.occ
          ]
        }:$PATH"

        nextcloud-occ maintenance:mode --on

        rm -r /var/lib/nextcloud/data
        cp -r /home/elias/backup/data /var/lib/nextcloud/data

        sudo -u postgres dropdb nextcloud
        sudo -u postgres createdb -O nextcloud nextcloud
        sudo -u postgres psql nextcloud < /home/elias/backup/database.bak
        rm -r /home/elias/backup

        nextcloud-occ maintenance:mode --off
      '';
    in
    {
      systemd.tmpfiles.rules = [
        "L+ /home/elias/backup.sh - - - - ${backupScript}"
        "L+ /home/elias/import.sh - - - - ${importScript}"
      ];
    };
}
