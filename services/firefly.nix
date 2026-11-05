{
  config,
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

  host = {
    name = "firefly";
    address = "192.168.0.201"; # firefly.dodekaeder.name
    ip = "192.168.0.201";
    port = 22;
    firewall = [ 80 ];
  };
in
{
  _module.args.host = host;
  imports = [ ../colmena.nix ];

  sops.secrets.firefly_key = {
    owner = "firefly-iii";
    group = "nginx";
    mode = "0400";
  };

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
      # ENABLE_REGISTRATION = "true";
    };
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "de_DE.UTF-8/UTF-8"
    ];
  };

  systemd.tmpfiles.rules = [
    "L+ /home/elias/backup.sh - - - - ${backupScript}"
  ];
}
