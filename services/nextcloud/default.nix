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
    firewall = [
      80
      443
    ];
  };
in
{
  networking.hosts = {
    "192.168.0.200" = [
      "cloud.dodekaeder.name"
    ];
  };
  _module.args.host = host;
  imports = [
    ../../system/colmena.nix
    "${
      builtins.fetchTarball {
        url = "https://github.com/onny/nixos-nextcloud-testumgebung/archive/fa6f062830b4bc3cedb9694c1dbf01d5fdf775ac.tar.gz";
        sha256 = "0gzd0276b8da3ykapgqks2zhsqdv4jjvbv97dsxg0hgrhb74z0fs";
      }
    }/nextcloud-extras.nix"
  ];
  networking.enableIPv6 = false;

  sops.secrets.nextcloud_elias_pwd = {
    owner = "nextcloud";
    group = "nextcloud";
    mode = "0400";
  };

  services.nextcloud = {
    enable = true;
    hostName = host.address;
    database.createLocally = true;
    config.dbtype = "pgsql";

    settings = {
      maintenance_window_start = 1;
      default_phone_region = "DE";
      log_type = "file";
      logfile = "${config.services.nextcloud.datadir}/nextcloud.log";
      serverid = 0;
      overwrite.cli.url = "https://cloud.dodekaeder.name";
      overwriteprotocol = "https";
      overwritehost = "cloud.dodekaeder.name";

      trusted_domains = [
        "cloud.dodekaeder.name"
      ];
      trusted_proxies = [
        "192.168.0.200"
      ];
      enforce_theme = "dark";
    };

    extraOptions = {
      mail_smtpmode = "sendmail";
      mail_sendmailmode = "pipe";
    };

    phpOptions = {
      "opcache.interned_strings_buffer" = 16;
      "opcache.memory_consumption" = 256;
      "opcache.max_accelerated_files" = 20000;
    };

    phpExtraExtensions = all: [
      all.pdo_pgsql
    ];

    # ── Apps ────────────────────────────────────────────────────────────────
    extraApps = {
      inherit (config.services.nextcloud.package.packages.apps)
        calendar
        contacts
        cospend
        notes
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
  systemd.services.nextcloud-custom-config = {
    path = [
      config.services.nextcloud.occ
    ];
    script = ''
      nextcloud-occ theming:config name "Dodekaeder Cloud"
      nextcloud-occ theming:config url "https://www.dodekaeder.name";
      nextcloud-occ theming:config slogan "A frosty home for your data.";
      nextcloud-occ theming:config primary_color "#4A2029";
      nextcloud-occ theming:config background ${./background.png}
      nextcloud-occ theming:config logo ${./logo.png}
      nextcloud-occ theming:config favicon ${./favicon.png}
      nextcloud-occ config:system:delete integrity.check.disabled
    '';
    after = [ "nextcloud-setup.service" ];
    wantedBy = [ "multi-user.target" ];
  };
  # Wepicon, Background, Colors, ...

  services.onlyoffice = {
    enable = true;
    hostname = "localhost";
    securityNonceFile = "${pkgs.writeText "nixos-test-onlyoffice-nonce.conf" ''
      set $secure_link_secret "nixostest";
    ''}";
  };

  services.epmd.listenStream = "0.0.0.0:4369";

  # Admin elias
  systemd.services.nextcloud-make-elias-admin = {
    description = "Make Elias a Nextcloud administrator";
    after = [ "nextcloud-setup.service" ];
    requires = [
      "nextcloud-setup.service"
      "nextcloud-ensure-users.service"
    ];
    wantedBy = [ "multi-user.target" ];

    path = [
      config.services.nextcloud.occ
    ];

    script = ''
      nextcloud-occ group:adduser admin elias || true
    '';
  };

  sops.secrets.mail_smtp_password = {
    owner = "root";
    mode = "0400";
  };

  programs.msmtp = {
    enable = true;
    setSendmail = true;

    accounts.default = {
      host = "mail.ecloud.global";
      port = 587;

      tls = true;
      tls_starttls = true;
      auth = true;

      user = "dodekaeder@murena.io";
      from = "dodekaeder@murena.io";

      passwordeval = "cat ${config.sops.secrets.mail_smtp_password.path}";
    };
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [
      {
        name = "nextcloud";
        ensureDBOwnership = true;
      }
    ];
  };

  # ── Backup ──────────────────────────────────────────────────────────────
  systemd.tmpfiles.rules = [
    "L+ /home/elias/backup.sh - - - - ${backupScript}"
  ];
}
