terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "4.6.0"
    }
  }
}

provider "docker" {
  context = "desktop-linux"
}


# ============================================================
# IMAGE
# ============================================================

resource "docker_image" "netshoot" {
  name         = "nicolaka/netshoot:latest"
  keep_locally = true
}


# ============================================================
# REAL NETWORK
# ============================================================

resource "docker_network" "real" {
  name = "real-net"

  ipam_config {
    subnet  = "172.20.0.0/24"
    gateway = "172.20.0.1"
  }
}


# ============================================================
# REAL SERVER
# ============================================================

resource "docker_container" "server_real" {
  name  = "server-real"
  image = docker_image.netshoot.image_id

  command = [
    "tail",
    "-f",
    "/dev/null"
  ]

  networks_advanced {
    name         = docker_network.real.name
    ipv4_address = "172.20.0.20"
  }
}


# ============================================================
# REAL CLIENT
# ============================================================

resource "docker_container" "client_real" {
  name  = "client-real"
  image = docker_image.netshoot.image_id

  command = [
    "tail",
    "-f",
    "/dev/null"
  ]

  capabilities {
    add = ["CAP_NET_ADMIN"]
  }

  networks_advanced {
    name         = docker_network.real.name
    ipv4_address = "172.20.0.10"
  }
}


# ============================================================
# DIGITAL TWIN NETWORK
# ============================================================

resource "docker_network" "twin" {
  name = "twin-net"

  ipam_config {
    subnet  = "172.21.0.0/24"
    gateway = "172.21.0.1"
  }
}


# ============================================================
# DIGITAL TWIN SERVER
# ============================================================

resource "docker_container" "server_twin" {
  name  = "server-twin"
  image = docker_image.netshoot.image_id

  command = [
    "tail",
    "-f",
    "/dev/null"
  ]

  networks_advanced {
    name         = docker_network.twin.name
    ipv4_address = "172.21.0.20"
  }
}


# ============================================================
# DIGITAL TWIN CLIENT
# ============================================================

resource "docker_container" "client_twin" {
  name  = "client-twin"
  image = docker_image.netshoot.image_id

  command = [
    "tail",
    "-f",
    "/dev/null"
  ]

  capabilities {
    add = ["CAP_NET_ADMIN"]
  }

  networks_advanced {
    name         = docker_network.twin.name
    ipv4_address = "172.21.0.10"
  }
}


# ============================================================
# DIGITAL TWIN BACKUP SERVER
# ============================================================

resource "docker_container" "server_twin_backup" {
  count = var.enable_backup_twin ? 1 : 0

  name  = "server-twin-backup"
  image = docker_image.netshoot.image_id

  command = [
    "tail",
    "-f",
    "/dev/null"
  ]

  networks_advanced {
    name         = docker_network.twin.name
    ipv4_address = "172.21.0.21"
  }
}


# ============================================================
# REAL BACKUP SERVER
# ============================================================

resource "docker_container" "server_real_backup" {
  count = var.enable_backup_real ? 1 : 0

  name  = "server-real-backup"
  image = docker_image.netshoot.image_id

  command = [
    "tail",
    "-f",
    "/dev/null"
  ]

  networks_advanced {
    name         = docker_network.real.name
    ipv4_address = "172.20.0.21"
  }
}