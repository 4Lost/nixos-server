data "sops_file" "secrets" {
  source_file = "../secrets/secrets.yaml"
}

locals {
  secrets = yamldecode(data.sops_file.secrets.raw)
}

module "nixos_template" {
  source = "./modules/nixos-template"

  node_name = var.node_name
}

module "lxc" {
  source = "./modules/lxc"

  node_name      = var.node_name
  subnet         = var.subnet
  rootfs_storage = var.rootfs_storage
  containers     = var.containers

  template_file_id = module.nixos_template.template_file_id

  sops_key_path = "${path.module}/../../sops/key.txt"
}




