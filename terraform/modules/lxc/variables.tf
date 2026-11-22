variable "node_name" {
  type = string
}

variable "subnet" {
  type = string
}

variable "rootfs_storage" {
  type = string
}

variable "containers" {
  type = map(object({
    vmid           = number
    hostname       = string
    cores          = number
    memory         = number
    disk           = number
    rootfs_storage = optional(string)
  }))
}

variable "template_file_id" {
  description = "Proxmox NixOS template ID"
  type        = string
}

variable "sops_key_path" {
  type = string
}
