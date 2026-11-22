{ ... }:

{
  flake.modules.nixos.nginx-nextcloud =
    { ... }:

    {
      services.nginx.streamConfig = ''
        upstream minecraft {
          server 192.168.0.209:43000;
        }

        server {
          listen 43000;
          proxy_pass minecraft;
          proxy_connect_timeout 10s;
          proxy_timeout 1h;
        }
      '';
    };
}
