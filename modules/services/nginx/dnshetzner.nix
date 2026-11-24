{ ... }:

{
  flake.modules.nixos.nginx-dns-updater =
    {
      dnsRecords,
      domainName,
      lib,
      pkgs,
      ...
    }:

    {
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

              source /run/secrets/nginx/hetzner-token
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
            "https://api.hetzner.cloud/v1/zones/${domainName}/rrsets/$record/AAAA/actions/set_records"
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
    };
}
