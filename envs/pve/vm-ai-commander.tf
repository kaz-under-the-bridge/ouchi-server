resource "proxmox_virtual_environment_vm" "ai_commander" {
  name      = local.vms.ai_commander.name
  node_name = local.node_name
  vm_id     = local.vms.ai_commander.vmid
  tags      = local.vms.ai_commander.tags

  agent {
    enabled = true
  }

  cpu {
    cores = local.vms.ai_commander.cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = local.vms.ai_commander.memory
  }

  disk {
    datastore_id = local.datastore_id
    file_id      = proxmox_virtual_environment_download_file.ubuntu_noble_cloud_image.id
    interface    = "scsi0"
    size         = local.vms.ai_commander.disk_size
    discard      = "on"
    iothread     = true
  }

  network_device {
    bridge = local.network.bridge
  }

  initialization {
    ip_config {
      ipv4 {
        address = "${local.vms.ai_commander.ip}/24"
        gateway = local.network.gateway
      }
    }
    dns {
      servers = [local.network.dns]
    }
    user_data_file_id = proxmox_virtual_environment_file.cloud_init_ai_commander.id
  }

  operating_system {
    type = "l26"
  }

  serial_device {}
}
