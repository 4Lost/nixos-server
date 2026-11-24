{ ... }:

{
  perSystem =
    { ... }:

    {
      terranix.terranixConfigurations.tf.modules = [
        (
          { ... }:

          {
            variable.state_passphrase = {
              type = "string";
              sensitive = true;
            };

            terraform.encryption = {
              key_provider.pbkdf2.main.passphrase = "\${var.state-passphrase}";
              method.aes_gcm.main.keys = "\${key_provider.pbkdf2.main}";

              state = {
                method = "method.aes_gcm.main";
                enforced = true;
              };

              plan = {
                method = "method.aes_gcm.main";
                enforced = true;
              };
            };
          }
        )
      ];
    };
}
