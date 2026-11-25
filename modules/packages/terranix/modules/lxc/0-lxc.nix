{ ... }:

{
  perSystem =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    {
      terranix.terranixConfigurations.tf.modules = [
        (
          { ... }:

          {

            options.modules.lxc = {
              enable = pkgs.mkEnableOption "bastion host infrastructure";
              vpcID = pkgs.mkOption {
                default = "\${ aws_default_vpc.default.id }";
                type = lib.types.str;
                description = "vpc id to which the bastion host should proxy";
              };
            };

            config = pkgs.mkIf (config.security.bastion.enable) {
              resource.aws_instance."bastion" = {
                ami = "ami-969ab1f6";
                instance_type = "t2.micro";
                associate_public_ip_address = true;
              };

              resource.aws_security_group."bastion-sg" = {
                name = "bastion-security-group";
                vpc_id = config.security.bastion.vpcId;
                ingress.protocol = "tcp";
                ingress.from_port = 22;
                ingress.to_port = 22;
                ingress.cidr_blocks = [ "0.0.0.0/0" ];
              };

              output."bastion_public_ip".value = "\${ aws_instance.bastion.public_ip }";
            };

          }
        )
      ];
    };
}
