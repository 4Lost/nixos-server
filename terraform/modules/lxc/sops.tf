resource "terraform_data" "distribute_sops_key" {
  for_each = var.containers

  triggers_replace = [
    proxmox_virtual_environment_container.container[each.key].id,
    filesha256(var.sops_key_path)
  ]


  provisioner "file" {
    source      = var.sops_key_path
    destination = "/tmp/key.txt"

    connection {
      type  = "ssh"
      host  = "${var.subnet}.${each.value.vmid}"
      user  = "elias"
      agent = true
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/sops",
      "sudo chmod 700 /etc/sops",
      "sudo mv /tmp/key.txt /etc/sops/key.txt",
      "sudo chmod 600 /etc/sops/key.txt"
    ]

    connection {
      type  = "ssh"
      host  = "${var.subnet}.${each.value.vmid}"
      user  = "elias"
      agent = true
    }
  }
}
