{ self, ... }:

{
  flake.modules.nixos.home-assistant =
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
        name = "home";
        address = "home.dodekaeder.name";
        ip = "192.168.0.203";
        port = 22;
        firewall = [ 80 ];
      };
    in
    {
      networking.enableIPv6 = false;

      _module.args.host = host;
      imports = with self.modules.nixos; [ colmena ];

      services.home-assistant = {
        enable = true;
        extraComponents = [
          # Components required to complete the onboarding
          "esphome"
          "met"
          "radio_browser"
        ];
        config = {
          # Includes dependencies for a basic setup
          # https://www.home-assistant.io/integrations/default_config/
          default_config = { };
        };
      };
      systemd.tmpfiles.rules = [
        "L+ /home/elias/backup.sh - - - - ${backupScript}"
      ];
    };
}
