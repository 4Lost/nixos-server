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
  '';

  host = {
    name = "nextcloud";
    address = "cloud.dodekaeder.name";
    ip = "192.168.0.202";
    port = 22;
    firewall = [ 80 ];
  };
in
{
  _module.args.host = host;
  imports = [
    ../colmena.nix
    "${
      builtins.fetchTarball {
        url = "https://github.com/onny/nixos-nextcloud-testumgebung/archive/fa6f062830b4bc3cedb9694c1dbf01d5fdf775ac.tar.gz";
        sha256 = "0gzd0276b8da3ykapgqks2zhsqdv4jjvbv97dsxg0hgrhb74z0fs";
      }
    }/nextcloud-extras.nix"
  ];

  sops.secrets.nextcloud_elias_pwd = {
    owner = "nextcloud";
    group = "nextcloud";
    mode = "0400";
  };

  services.nextcloud = {
    enable = true;
    hostName = host.address;
    config.dbtype = "sqlite";

    settings = {
      maintenance_window_start = 1;
      default_phone_region = "DE";
      log_type = "systemd";
      serverid = 0;
    };

    extraOptions = {
      mail_smtpmode = "sendmail";
      mail_sendmailmode = "pipe";
    };

    # ── Apps ────────────────────────────────────────────────────────────────
    extraApps = {
      inherit (config.services.nextcloud.package.packages.apps)
        calendar
        contacts
        cospend
        onlyoffice
        ;
    };

    # ── Faster image preview ────────────────────────────────────────────────
    imaginary.enable = true;
    settings.preview_format = "webp";

    # ── Usermanagement ──────────────────────────────────────────────────────
    ensureUsers = {
      elias = {
        email = "elias.schroeter@e.email";
        passwordFile = config.sops.secrets."nextcloud_elias_pwd".path;
      };
    };
  };

  # ── Themes ──────────────────────────────────────────────────────────────
  # systemd.services.nextcloud-custom-config = {
  #   path = [
  #     config.services.nextcloud.occ
  #   ];
  #   script = ''
  #     nextcloud-occ theming:config name "My Cloud"
  #     nextcloud-occ theming:config url "https://cloud.mine.com";
  #     nextcloud-occ theming:config privacyUrl "https://www.mine.com/privacy";
  #     nextcloud-occ theming:config color "#3253a5";
  #     nextcloud-occ theming:config logo ${./logo.png}
  #   '';
  #   after = [ "nextcloud-setup.service" ];
  #   wantedBy = [ "multi-user.target" ];
  # };
  # Wepicon, Background, Colors, ...

  services.onlyoffice = {
    enable = true;
    hostname = "localhost";
    securityNonceFile = "${pkgs.writeText "nixos-test-onlyoffice-nonce.conf" ''
      set $secure_link_secret "nixostest";
    ''}";
  };

  services.epmd.listenStream = "0.0.0.0:4369";

  # ── Backup ──────────────────────────────────────────────────────────────
  systemd.tmpfiles.rules = [
    "L+ /home/elias/backup.sh - - - - ${backupScript}"
  ];
}
