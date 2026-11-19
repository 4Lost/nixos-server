{
  config,
  lib,
  pkgs,
  ...
}:

let
  dnsRecords = [
    "@"
    "cloud"
    "firefly"
  ];
  host = {
    name = "nginx";
    address = "192.168.0.200";
    ip = "192.168.0.200";
    port = 22;
    firewall = [
      80
      443
    ];
  };
  domainName = "dodekaeder.name";
in
{
  networking.enableIPv6 = true;

  _module.args.host = host;

  imports = [
    ../../system/colmena.nix
  ];

  services.nginx = {
    enable = true;
    # recommendedProxySettings = true;
    # recommendedTlsSettings = true;

    virtualHosts = {
      "${domainName}" = {
        forceSSL = true;
        useACMEHost = "${domainName}";

        acmeRoot = null;

        locations."/" = {
          return = "200 'Hello from NixOS!'";
          extraConfig = ''
            default_type text/plain;
          '';
        };
      };
      "firefly.${domainName}" = import ./firefly.nix { inherit domainName; };
      "cloud.${domainName}" = import ./nextcloud.nix { inherit domainName; };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "dodekaeder@murena.io";

    certs."${domainName}" = {
      extraDomainNames = [ "*.${domainName}" ];

      dnsProvider = "hetzner";
      dnsResolver = "[2606:4700:4700::1111]:53";
      environmentFile = config.sops.secrets.hetzner-api-token.path;

      group = config.services.nginx.group;
    };
  };

  sops.secrets.hetzner-api-token.mode = "0400";

  systemd.services.hetzner-dns-update = {
    description = "Update Hetzner DNS AAAA records with the current public IPv6 address";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = false;
    };

    script = ''
          #!/usr/bin/env bash
          export PATH="${pkgs.coreutils}/bin:${pkgs.bash}/bin:${pkgs.curl}/bin:$PATH"

          source /run/secrets/hetzner-api-token
          token="$HETZNER_API_TOKEN"
          current_ip="$(curl -6 https://ifconfig.me)"
          state_file="/var/lib/hetzner-dns-update/last-ip"

          if [ -f "$state_file" ] && [ "$(cat "$state_file")" = "$current_ip" ]; then
            exit 0
          fi

          for record in ${lib.concatStringsSep " " dnsRecords}; do
      curl -fsS \
        -X POST \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json" \
        -d "{\"records\":[{\"value\":\"$current_ip\"}]}" \
        "https://api.hetzner.cloud/v1/zones/dodekaeder.name/rrsets/$record/AAAA/actions/set_records"
          done

          mkdir -p /var/lib/hetzner-dns-update
          printf '%s' "$current_ip" > "$state_file"
    '';
  };

  systemd.timers.hetzner-dns-update = {
    wantedBy = [ "timers.target" ];

    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "5min";
      Unit = "hetzner-dns-update.service";
    };
  };
}
