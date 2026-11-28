{ ... }:

{
  flake.modules.nixos.network =
    { ... }:

    {
      networking = {
        defaultGateway = {
          address = "192.168.0.1";
          interface = "eth0";
        };
        useDHCP = false;
        nameservers = [
          "1.1.1.1"
          "2a02:8100:c0:249::4:1101"
          "2a02:8100:c0:241::4:1101"
        ];
      };

      services.resolved = {
        enable = true;

        settings.Resolve = {
          DNS = [
            "1.1.1.1"
            "2a02:8100:c0:249::4:1101"
            "2a02:8100:c0:241::4:1101"
          ];
          Cache = true;
          CacheFromLocalhost = true;
        };
      };
    };
}
