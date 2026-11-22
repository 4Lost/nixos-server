{ ... }:

{
  flake.modules.nixos.network =
    { ... }:

    {
      networking = {
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
          Cache = true;
          CacheFromLocalhost = true;
        };
      };
    };
}
