{ ... }:

{
  perSystem =
    { ... }:

    {
      _module.args.inventory = {
        node-name = "prox";
        subnet = "192.168.0";
        storage = "data";
        sops-key-path = "\${path.root}/../../sops/key.txt";
        template-path = "\${path.root}/build/nixos-custom-lxc.tar.xz";
        template-file = "local:vztmpl/nixos-custom-lxc.tar.xz";

        containers = [
          {
            name = "nginx";
            vmId = 200;

            cores = 1;
            memory = 2048;
            diskSize = 16;
          }
          {
            name = "firefly";
            vmId = 201;

            cores = 1;
            memory = 2048;
            diskSize = 16;
          }
          {
            name = "nextcloud";
            vmId = 202;

            cores = 2;
            memory = 4096;
            diskSize = 1700;
          }
          {
            name = "home";
            vmId = 203;

            cores = 1;
            memory = 4096;
            diskSize = 16;
          }
          {
            name = "wiki";
            vmId = 204;

            cores = 1;
            memory = 4096;
            diskSize = 16;
          }
          {
            name = "minecraft";
            vmId = 209;

            cores = 2;
            memory = 4096;
            diskSize = 16;
          }
        ];
      };
    };
}
