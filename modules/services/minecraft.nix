{ self, ... }:

{
  flake.modules.nixos.minecraft =
    {
      pkgs,
      ...
    }:

    let
      backupScript = pkgs.writeShellScript "backup.sh" ''
        #!/usr/bin/env bash

        export PATH="${pkgs.coreutils}/bin:${pkgs.bash}/bin:$PATH"

        rm -rf /home/elias/backup
        mkdir /home/elias/backup
      ''; # TODO

      host = {
        name = "nextcloud";
        address = "192.168.0.209"; # cloud.dodekaeder.name
        ip = "192.168.0.209";
        port = 22;
        firewall = [ 43000 ];
      };
    in
    {
      _module.args.host = host;
      imports = with self.modules.nixos; [ colmena ];
      networking.enableIPv6 = false;

      services.minecraft-server = {
        enable = true;
        eula = true;
        openFirewall = true;
        declarative = true;
        serverProperties = {
          server-port = 43000;
          difficulty = 3;
          gamemode = 1;
          max-players = 20;
          motd = "Small gaming world";
          white-list = false;
          allow-cheats = true;
        };
        jvmOpts = "-Xms2048M -Xmx2048M";
      };
      services.epmd.listenStream = "0.0.0.0:4369";

      nixpkgs.config.allowUnfree = true;

      # ── Backup ──────────────────────────────────────────────────────────────
      systemd.tmpfiles.rules = [
        "L+ /home/elias/backup.sh - - - - ${backupScript}"
      ];
    };
}
