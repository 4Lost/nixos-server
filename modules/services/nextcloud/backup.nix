{ ... }:

{
  flake.modules.nixos.nextcloud-backup =
    { pkgs, ... }:

    let
      backupScript = pkgs.writeShellScript "backup.sh" ''
        #!/usr/bin/env bash

        export PATH="${pkgs.coreutils}/bin:${pkgs.bash}/bin:$PATH"

        rm -rf /home/elias/backup
        mkdir /home/elias/backup
      '';
    in

    {
      systemd.tmpfiles.rules = [
        "L+ /home/elias/backup.sh - - - - ${backupScript}"
      ];
    };
}
