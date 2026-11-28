{ ... }:

{
  flake.modules.nixos.firefly-backup =
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

        mkdir /home/elias/backup

        echo "Database"
        sudo cp -r /var/lib/firefly-iii/storage/database /home/elias/backup/database

        echo "Upload"
        sudo cp -r /var/lib/firefly-iii/storage/upload /home/elias/backup/upload

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

        echo "Database"
        sudo mkdir -p /var/lib/firefly-iii/storage
        sudo cp -r /home/elias/backup/database /var/lib/firefly-iii/storage/database

        echo "Upload"
        sudo mkdir -p /var/lib/firefly-iii/storage/upload
        sudo cp -r /home/elias/backup/upload /var/lib/firefly-iii/storage/upload

        sudo chown -R firefly-iii /var/lib/firefly-iii
      '';
    in
    {
      systemd.tmpfiles.rules = [
        "L+ /home/elias/backup.sh - - - - ${backupScript}"
        "L+ /home/elias/import.sh - - - - ${importScript}"
      ];
    };
}
