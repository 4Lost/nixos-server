{ inputs, self, ... }:

{
  flake.modules.nixos.nextcloud =
    {
      config,
      ...
    }:

    let
      host = {
        name = "nextcloud";
        address = "cloud.dodekaeder.name";
        ip = "192.168.0.202";
        port = 22;
        firewall = [
          80
          443
        ];
      };
    in
    {
      networking = {
        enableIPv6 = false;
        hosts."192.168.0.200" = [ "cloud.dodekaeder.name" ];
      };

      _module.args.host = host;
      imports = with self.modules.nixos; [
        "${inputs.nextcloud-testumgebung}/nextcloud-extras.nix"

        colmena

        nextcloud-apps
        nextcloud-backup
        nextcloud-database
        nextcloud-mail
        nextcloud-theme
        nextcloud-php
        nextcloud-user
      ];

      services.nextcloud = {
        enable = true;
        hostName = host.address;

        settings = {
          maintenance_window_start = 1;
          default_phone_region = "DE";
          log_type = "file";
          logfile = "${config.services.nextcloud.datadir}/nextcloud.log";
          serverid = 0;

          overwrite.cli.url = "https://cloud.dodekaeder.name";
          overwriteprotocol = "https";
          overwritehost = "cloud.dodekaeder.name";
          trusted_domains = [ "cloud.dodekaeder.name" ];
          trusted_proxies = [ "192.168.0.200" ];

          enforce_theme = "dark";
        };
      };
    };
}
