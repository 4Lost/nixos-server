{ ... }:

{
  enableACME = true;
  forceSSL = true;

  locations."/" = {
    proxyPass = "http://192.168.0.201:80";
    proxyWebsockets = true; # needed if you need to use WebSocket

    extraConfig = ''
      proxy_set_header X-Forwarded-Host $host;
      proxy_set_header X-Forwarded-Ssl on;
    '';
  };
}
