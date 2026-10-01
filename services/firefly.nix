{ pkgs, ... }:

let
  backupScript = pkgs.writeShellScript "backup.sh" ''
    rm -rf /home/elias/backup
    mkdir /home/elias/backup
    cp /var/lib/firefly-iii/storage/database /home/elias/backup/database
    cp /var/lib/firefly-iii/storage/upload /home/elias/backup/upload
    cp /var/lib/firefly-iii-secrets/app-key /home/elias/backup/app-key
  '';
in
{
  networking = {
    interfaces.eth0.ipv4.addresses = [
      {
        address = "192.168.3.201";
        prefixLength = 24;
      }
    ];

    firewall.allowedTCPPorts = [ 80 ];
  };

  services.firefly-iii = {
    enable = true;

    enableNginx = true;
    virtualHost = "firefly.local";
    dataDir = "/var/lib/firefly-iii";

    settings = {
      APP_ENV = "production";
      APP_KEY_FILE = "/var/lib/firefly-iii-secrets/app-key";
      APP_URL = "http://192.168.3.201";
      DB_CONNECTION = "sqlite";
    };
  };

  systemd.tmpfiles.rules = [
    "L+ /home/elias/backup.sh - - - - ${backupScript}"
  ];
}
