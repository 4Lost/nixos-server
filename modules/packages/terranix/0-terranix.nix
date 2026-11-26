{ ... }:

{
  perSystem =
    {
      config,
      pkgs,
      tofu,
      ...
    }:

    {
      _module.args.tofu = pkgs.opentofu.withPlugins (p: [
        p.bpg_proxmox
        # (p.mkProvider {
        #   owner = "lord-kyron";
        #   repo = "terraform-provider-phpipam";
        #   rev = "v1.7.3";
        #   hash = "sha256-1OzxvMjwQocl5BirPMrQ7tFt2Emau5nWaxyfJ3mQzog=";
        #   vendorHash = null;
        #   homepage = "https://registry.terraform.io/providers/lord-kyron/phpipam";
        #   provider-source-address = "registry.terraform.io/lord-kyron/phpipam";
        #   spdx = "Apache-2.0";
        # })
      ]);
      terranix.terranixConfigurations.tf = {
        workdir = "terraform";
        terraformWrapper = {
          package = tofu;
          extraRuntimeInputs = [ pkgs.sops ];
          prefixText = ''
            _tofu_secrets="''${PRJ_ROOT:-$PWD}/../secrets/tofu.env"
            if [ -f "$_tofu_secrets" ]; then
              set -a
              eval "$(sops -d --output-type dotenv "$_tofu_secrets")"
              set +a
            else
              echo "warning: $_tofu_secrets not found, provider credentials not loaded" >&2
            fi
          '';
        };
      };
    };
}
