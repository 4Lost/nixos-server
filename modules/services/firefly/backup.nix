{ ... }:

{
  flake.modules.nixos.firefly =
    {
      config,
      domainName,
      pkgs,
      ...
    }:

    let
      backupScript = pkgs.writeShellScript "backup.sh" ''
        #!/usr/bin/env bash

        export PATH="${pkgs.coreutils}/bin:${pkgs.bash}/bin:$PATH"

        rm -rf /home/elias/backup
        mkdir /home/elias/backup
        cp -r /var/lib/firefly-iii/storage/database /home/elias/backup/database
        cp -r /var/lib/firefly-iii/storage/upload /home/elias/backup/upload
      '';
      importScript = pkgs.writeShellScript "backup.sh" ''
        #!/usr/bin/env bash

        export PATH="${pkgs.coreutils}/bin:${pkgs.bash}/bin:$PATH"

        rm -rf /home/elias/backup
        mkdir /home/elias/backup
        cp -r /var/lib/firefly-iii/storage/database /home/elias/backup/database
        cp -r /var/lib/firefly-iii/storage/upload /home/elias/backup/upload
      '';
    in
    {
      systemd.tmpfiles.rules = [
        "L+ /home/elias/backup.sh - - - - ${backupScript}"
        "L+ /home/elias/import.sh - - - - ${importScript}"
      ];
    };
}
