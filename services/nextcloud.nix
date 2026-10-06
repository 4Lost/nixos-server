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
  '';
in
{
  sops.secrets.nextcloud_pwd = { };
  environment.etc."nextcloud-admin-pass".text = config.sops.secrets."nextcloud_key";

  services.nextcloud = {
    enable = true;
    hostName = host.hostname;
    config.adminpassFile = config.sops.secrets."nextcloud_pwd".path;
    config.dbtype = "sqlite";
    settings = {
      maintenance_window_start = 1;
      default_phone_region = "DE";
      log_type = "systemd";
      serverid = 0;
    };
  };

  systemd.tmpfiles.rules = [
    "L+ /home/elias/backup.sh - - - - ${backupScript}"
  ];
}
