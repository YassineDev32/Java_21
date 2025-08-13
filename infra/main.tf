terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean" 
      version = "~> 2.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.0"
    }
    
  }
}

provider "vault" {
  address = "http://127.0.0.1:8200"
}


data "vault_kv_secret_v2" "do_token" {
  mount = "secret"
  name  = "do"
}

locals {
  do_token    = data.vault_kv_secret_v2.do_token.data["token"]
  ssh_key_id  = data.vault_kv_secret_v2.do_token.data["ssh_key"]
}

provider "digitalocean" {
  token = local.do_token
}


resource "digitalocean_droplet" "droplets" {
  count  = length(var.droplets)
  name   = var.droplets[count.index].name
  region = var.region
  size   = var.droplets[count.index].size
  image  = var.image

  ssh_keys = [local.ssh_key_id]

  tags = [var.droplets[count.index].tag]
}

output "droplet_ips" {
  value = {
    for idx, droplet in digitalocean_droplet.droplets :
    var.droplets[idx].name => droplet.ipv4_address
  }
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.tftpl", {
    droplets = [
      for i in range(length(digitalocean_droplet.droplets)) : {
        name = var.droplets[i].name
        ip   = digitalocean_droplet.droplets[i].ipv4_address
        tag  = var.droplets[i].tag
      }
    ]
  })

  filename = "../ansible/${path.module}/inventory.ini"
}

