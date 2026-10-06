{
  firefly = {
    hostname = "firefly";
    system = "x86_64-linux";
    address = "192.168.3.201"; # firefly.dodekaeder.name
    ip = "192.168.3.201";
    firewall = [ 80 ];
  };
  nextcloud = {
    hostname = "nextcloud";
    system = "x86_64-linux";
    address = "192.168.3.202"; # cloud.dodekaeder.name
    ip = "192.168.3.202";
    firewall = [ 80 ];
  };
}
