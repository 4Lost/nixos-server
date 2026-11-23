{ self, ... }:

{
  flake.modules.nixos.nginx =
    {
      config,
      domainName,
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
    in
    {
      networking.enableIPv6 = true;

      _module.args = {
        dnsRecords = dnsRecords;
        host = host;
      };

      imports = with self.modules.nixos; [
        colmena
        nginx-dns-updater
        nginx-firefly
        nginx-nextcloud
      ];

      services.nginx = {
        enable = true;
        # recommendedProxySettings = true;
        # recommendedTlsSettings = true;

        virtualHosts."${domainName}" = {
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
      };

      sops.secrets.hetzner-api-token.mode = "0400";

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
    };
}
