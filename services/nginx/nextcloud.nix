{ domainName, ... }:

{
  forceSSL = true;
  useACMEHost = "${domainName}";

  locations."/" = {
    proxyPass = "http://192.168.0.202:80";

    extraConfig = ''
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_ssl_server_name on;
      proxy_pass_header Authorization;
      add_header Strict-Transport-Security "max-age=15552000" always;
    '';
  };

  locations."= /.well-known/carddav" = {
    return = "301 /remote.php/dav/";
  };

  locations."= /.well-known/caldav" = {
    return = "301 /remote.php/dav/";
  };

  locations."^~ /.well-known" = {
    return = "301 /index.php$request_uri";
  };
}
