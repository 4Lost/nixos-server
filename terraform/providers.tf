provider "proxmox" {
  endpoint  = local.secrets.terraform.proxmox.api.url
  api_token = "${local.secrets.terraform.proxmox.api.token-id}=${local.secrets.terraform.proxmox.api.token-secret}"

  insecure = true
}

provider "sops" {}
