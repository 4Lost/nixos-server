{ ... }:

{
  perSystem =
    { ... }:

    {
      terranix.terranixConfigurations.tf.modules = [
        (
          { ... }:

          {
            variable = {
              state_passphrase = {
                type = "string";
                sensitive = true;
              };

              proxmox_api_url = {
                type = "string";
                sensitive = true;
              };

              proxmox_api_token_id = {
                type = "string";
                sensitive = true;
              };

              proxmox_api_token_secret = {
                type = "string";
                sensitive = true;
              };
            };

            provider."proxmox" = {
              endpoint = "\${var.proxmox_api_url}";
              api_token = "\${var.proxmox_api_token_id}=\${var.proxmox_api_token_secret}";

              insecure = true;
            };

            terraform = {
              required_version = ">= 1.3.0";

              required_providers = {
                proxmox = {
                  source = "bpg/proxmox";
                  version = ">= 0.105.0";
                };
              };
            };
          }
        )
      ];
    };
}
