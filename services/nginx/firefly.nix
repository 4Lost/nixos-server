{ domainName, ... }:

{
  forceSSL = true;
  useACMEHost = domainName;

  locations."/" = {
    proxyPass = "http://192.168.0.201:80";
    proxyWebsockets = true; # needed if you need to use WebSocket

    extraConfig = ''
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header X-Forwarded-Host $host;
      proxy_set_header X-Forwarded-Ssl on;
    '';
  };
}
