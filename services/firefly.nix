{ ... }:

{
  networking = {
    interfaces.eth0.ipv4.addresses = [
      {
        address = "192.168.3.201";
        prefixLength = 24;
      }
    ];
  };

  services.firefly-iii = {
    enable = true;

    enableNginx = true;
    virtualHost = "firefly.local";
    dataDir = "/var/lib/firefly-iii";

    settings = {
      APP_ENV = "production";
      APP_KEY_FILE = "/var/lib/firefly-iii-secrets/app-key";
      APP_URL = "http://192.168.3.201";
      DB_CONNECTION = "sqlite";
    };
  };
}
