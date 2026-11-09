{
  lib,
  pkgs,
  ...
}:

let
  dnsRecords = [
    "firefly"
    "cloud"
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
in
{
  _module.args.host = host;
  imports = [ ../../colmena.nix ];

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = {
      "firefly.dodekaeder.name" = import ./firefly.nix;
      "cloud.dodekaeder.name" = import ./nextcloud.nix;
    };
  };

  security.acme = {
    acceptTerms = true;
    default.email = "elias.schroeter@e.email";

    certs = {
      "firefly.dodekaeder.name" = { };
      "cloud.dodekaeder.name" = { };
    };
  };

  sops.secrets.hetzner-api-token.mode = "0400";

  systemd.services.hetzner-dns-update = {
    description = "Update Hetzner DNS A records with the current public IPv4 address";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "oneshot";
      EnvironmentFile = "/etc/hetzner-dns.env";
    };

    script = ''
        #!/usr/bin/env bash

        export PATH="${pkgs.coreutils}/bin:${pkgs.bash}/bin:$PATH"

      token="$(cat /run/secrets/hetzner-api-token)"
      current_ip="$(curl -fsS https://api.ipify.org)"
      state_file="/var/lib/hetzner-dns-update/last-ip"

      if [ -f "$state_file" ] && [ "$(cat "$state_file")" = "$current_ip" ]; then
        exit 0
      fi

      for record in ${lib.concatStringsSep " " dnsRecords}; do
        curl -fsS \
          -X PUT \
          -H "Authorization: Bearer $token" \
          -H "Content-Type: application/json" \
          -d "{\"records\":[{\"value\":\"$current_ip\"}]}" \
          "https://api.hetzner.cloud/v1/zones/dodekaeder.name/rrsets/$record/A"
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
