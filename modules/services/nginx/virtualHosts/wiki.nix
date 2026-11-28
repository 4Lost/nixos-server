{ ... }:

{
  flake.modules.nixos.nginx-wiki =
    { domainName, ... }:

    {
      services.nginx.virtualHosts."wiki.${domainName}" = {
        forceSSL = true;
        useACMEHost = domainName;

        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://192.168.0.204:3000";
        };
      };
    };
}
