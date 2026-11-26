{ ... }:

{
  perSystem =
    {
      inventory,
      lib,
      ...
    }:

    {
      terranix.terranixConfigurations.tf.modules = [
        (
          { ... }:

          let
            create-lxc =
              { container, ... }:

              {
                "${container.name}" = {
                  depends_on = [ "proxmox_virtual_environment_file.nixos" ];

                  node_name = "${inventory.node-name}";
                  vm_id = toString container.vmId;
                  description = "Managed by Terraform";

                  unprivileged = true;
                  started = true;
                  start_on_boot = true;
                  features.nesting = true;

                  cpu.cores = toString container.cores;
                  memory.dedicated = toString container.memory;

                  disk = {
                    datastore_id = "${inventory.storage}";
                    size = toString container.diskSize;
                  };

                  operating_system = {
                    template_file_id = "${inventory.template-file}";
                    type = "nixos";
                  };

                  initialization = {
                    hostname = "${container.name}";
                    dns.servers = [ "1.1.1.1" ];

                    ip_config.ipv4 = {
                      address = "${inventory.subnet}.${toString container.vmId}/24";
                      gateway = "${inventory.subnet}.1";
                    };
                  };

                  network_interface = {
                    name = "eth0";
                    bridge = "vmbr0";
                  };

                  lifecycle.prevent_destroy = true;
                };
              };
          in
          {
            resource."proxmox_virtual_environment_container" = lib.zipAttrs (
              lib.map (container: create-lxc { inherit container; }) inventory.containers
            );
          }
        )
      ];
    };
}
