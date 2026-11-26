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
            deploy-sops-key =
              { container, ... }:

              {
                "${container.name}" = {
                  triggers_replace = [
                    "\${proxmox_virtual_environment_container.${container.name}.id}"
                    "\${filesha256(\"${inventory.sops-key-path}\")}"
                  ];

                  provisioner."file" = {
                    source = "${inventory.sops-key-path}";
                    destination = "/tmp/key.txt";

                    connection = {
                      type = "ssh";
                      host = "${toString inventory.subnet}.${toString container.vmId}";
                      user = "elias";
                      agent = true;
                    };
                  };

                  provisioner."remote-exec" = {
                    inline = [
                      "sudo mkdir -p /etc/sops"
                      "sudo chmod 700 /etc/sops"
                      "sudo mv /tmp/key.txt /etc/sops/key.txt"
                      "sudo chmod 600 /etc/sops/key.txt"
                    ];

                    connection = {
                      type = "ssh";
                      host = "${toString inventory.subnet}.${toString container.vmId}";
                      user = "elias";
                      agent = true;
                    };
                  };
                };
              };
          in
          {
            resource."terraform_data" = lib.zipAttrs (
              lib.map (container: deploy-sops-key { inherit container; }) inventory.containers
            );
          }
        )
      ];
    };
}
