{ ... }:

{
  perSystem =
    { ... }:

    {
      terranix.terranixConfigurations.tf.modules = [
        (
          { ... }:

          {
            provider."proxmox" = {
              endpoint = "\${var.proxmox-api-url}";
              api_token = "\${var.proxmox-api-token-id}=\${var.proxmox-api-token-secret}";

              insecure = true;
            };
          }
        )
      ];
    };
}
