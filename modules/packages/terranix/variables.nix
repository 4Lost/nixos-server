{ ... }:

{
  perSystem =
    { ... }:

    {
      terranix.terranixConfigurations.tf.modules = [
        (
          { ... }:

          {
            variable."node_name".type = "string";

            variable."subnet" = {
              type = "string";
              default = "192.168.0";
            };

            variable."rootfs_storage" = {
              type = "string";
              default = "data";
            };

            variable."containers" = {
              description = "LXC container configurations";

              type = ''
                map(object({
                    hostname = string
                    vmid     = number

                    cores  = number
                    memory = number
                    disk   = number
                  }))'';
            };

            variable."ssh_private_key" = {
              description = "Path to the SSH private key used to access LXC containers";
              type = "string";
              sensitive = true;
            };
          }
        )
      ];
    };
}
