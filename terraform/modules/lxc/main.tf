resource "proxmox_virtual_environment_container" "container" {
  for_each = var.containers

  node_name = var.node_name
  vm_id     = each.value.vmid

  description = "Managed by Terraform"

  unprivileged  = true
  started       = true
  start_on_boot = true

  features {
    nesting = true
  }

  cpu {
    cores = each.value.cores
  }

  memory {
    dedicated = each.value.memory
  }

  disk {
    datastore_id = coalesce(
      each.value.rootfs_storage,
      var.rootfs_storage
    )

    size = each.value.disk
  }

  operating_system {
    template_file_id = var.template_file_id
    type             = "nixos"
  }

  initialization {
    hostname = each.value.hostname

    dns {
      servers = ["1.1.1.1"]
    }

    ip_config {
      ipv4 {
        address = "${var.subnet}.${each.value.vmid}/24"
        gateway = "${var.subnet}.1"
      }
    }
  }

  network_interface {
    name   = "eth0"
    bridge = "vmbr0"
  }

  lifecycle {
    prevent_destroy = true
  }
}
