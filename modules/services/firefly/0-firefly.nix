{ self, ... }:

{
  flake.modules.nixos.firefly =
    {
      config,
      domainName,
      pkgs,
      ...
    }:

    let
      host = {
        name = "firefly";
        address = "firefly.${domainName}";
        ip = "192.168.0.201";
        port = 22;
        firewall = [ 80 ];
      };
    in
    {
      networking.enableIPv6 = false;

      _module.args.host = host;
      imports = with self.modules.nixos; [
        colmena
        firefly-backup
      ];

      services.firefly-iii = {
        enable = true;

        enableNginx = true;
        virtualHost = host.address;
        dataDir = "/var/lib/firefly-iii";

        settings = {
          APP_ENV = "production";
          APP_KEY_FILE = config.sops.secrets."firefly/key".path;
          APP_URL = "http://${host.address}";
          DB_CONNECTION = "sqlite";
          TRUSTED_PROXIES = "192.168.0.200";
          # ENABLE_REGISTRATION = "true";
        };
      };

      sops.secrets."firefly/key" = {
        owner = "firefly-iii";
        group = "nginx";
        mode = "0400";
      };

      i18n = {
        defaultLocale = "en_US.UTF-8";
        supportedLocales = [
          "en_US.UTF-8/UTF-8"
          "de_DE.UTF-8/UTF-8"
        ];
      };
    };
}
