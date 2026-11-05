{ host, ... }:

{
  deployment = {
    targetHost = host.ip;
    targetPort = host.port;
    targetUser = "elias";
    tags = [ ];
  };

  networking = {
    hostName = host.name;

    interfaces.eth0.ipv4.addresses = [
      {
        address = host.ip;
        prefixLength = 24;
      }
    ];

    firewall.allowedTCPPorts = host.firewall;
  };
}
