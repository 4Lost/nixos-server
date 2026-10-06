{
  config,
  host,
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
in
{
  sops.secrets.firefly_key = { };
  services.firefly-iii = {
    enable = true;

    enableNginx = true;
    virtualHost = host.address;
    dataDir = "/var/lib/firefly-iii";

    settings = {
      APP_ENV = "production";
      APP_KEY_FILE = config.sops.secrets."firefly_key".path;
      APP_URL = "http://${host.address}";
      DB_CONNECTION = "sqlite";
    };
  };

  systemd.tmpfiles.rules = [
    "L+ /home/elias/backup.sh - - - - ${backupScript}"
  ];
}
