provider "proxmox" {
  endpoint  = local.secrets.proxmox.api_url
  api_token = "${local.secrets.proxmox.api_token_id}=${local.secrets.proxmox.api_token_secret}"

  insecure = true
}

provider "sops" {}
