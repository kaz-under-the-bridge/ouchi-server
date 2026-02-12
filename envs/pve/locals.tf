locals {
  node_name    = "pve-local"
  datastore_id = "local-lvm"

  # ネットワーク共通設定
  network = {
    bridge  = "vmbr0"
    subnet  = "192.168.1.0/24"
    gateway = var.network_gateway
    dns     = var.network_dns
  }

  # VM 定義
  vms = {
    nfs_server = {
      name      = "nfs-server"
      vmid      = 200
      cores     = 2
      memory    = 2048
      disk_size = 20
      ip        = "192.168.1.220"
      tags      = ["terraform", "nfs"]
    }
    ai_commander = {
      name      = "ai-commander"
      vmid      = 201
      cores     = 4
      memory    = 12288
      disk_size = 50
      ip        = "192.168.1.221"
      tags      = ["terraform", "dev"]
    }
  }
}
