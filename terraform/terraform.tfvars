node_name = "prox"

containers = {
  nginx = {
    hostname = "nginx"
    vmid     = 200

    cores  = 1
    memory = 2048
    disk   = 16
  }

  firefly = {
    hostname = "firefly"
    vmid     = 201

    cores  = 1
    memory = 2048
    disk   = 16
  }

  nextcloud = {
    hostname = "nextcloud"
    vmid     = 202

    cores  = 2
    memory = 4096
    disk   = 1700
  }

  home-assistant = {
    hostname = "home"
    vmid     = 203

    cores  = 2
    memory = 4096
    disk   = 16
  }

  minecraft = {
    hostname = "minecraft"
    vmid     = 209

    cores  = 2
    memory = 4096
    disk   = 16
  }
}

ssh_private_key = "~/.ssh/id_rsa"
