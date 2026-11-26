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

          {
            locals.configuration_hash = "\${filesha256(\"\${path.root}/lxc-configuration.nix\")}";

            resource."terraform_data"."build_nixos" = {
              triggers_replace = [
                "\${local.configuration_hash}"
              ];

              provisioner."local-exec" = {
                command = "./build.sh";
                working_dir = "\${path.root}/";
              };
            };

            resource."proxmox_virtual_environment_file"."nixos" = {
              content_type = "vztmpl";
              datastore_id = "local";
              node_name = "${inventory.node-name}";

              source_file.path = "\${path.root}/build/nixos-custom-lxc.tar.xz";

              depends_on = [ "terraform_data.build_nixos" ];

              lifecycle.create_before_destroy = true;
            };
          }
        )
      ];
    };
}
