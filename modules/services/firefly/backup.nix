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
        cp -r /var/lib/firefly-iii/storage/database /home/elias/backup/database
        cp -r /var/lib/firefly-iii/storage/upload /home/elias/backup/upload
      '';
      importScript = pkgs.writeShellScript "backup.sh" ''
        #!/usr/bin/env bash

        export PATH="${
          pkgs.lib.makeBinPath [
            pkgs.coreutils
            pkgs.bash
          ]
        }:$PATH"

        mkdir -p /var/lib/firefly-iii/storage
        cp -r /home/elias/backup/database /var/lib/firefly-iii/storage/database

        mkdir -p /var/lib/firefly-iii/storage/upload
        cp -r /home/elias/backup/upload /var/lib/firefly-iii/storage/upload
      '';
    in
    {
      systemd.tmpfiles.rules = [
        "L+ /home/elias/backup.sh - - - - ${backupScript}"
        "L+ /home/elias/import.sh - - - - ${importScript}"
      ];
    };
}
