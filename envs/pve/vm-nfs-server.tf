resource "proxmox_virtual_environment_vm" "nfs_server" {
  name      = local.vms.nfs_server.name
  node_name = local.node_name
  vm_id     = local.vms.nfs_server.vmid
  tags      = local.vms.nfs_server.tags

  agent {
    enabled = true
  }

  cpu {
    cores = local.vms.nfs_server.cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = local.vms.nfs_server.memory
  }

  # Root ディスク (Ubuntu cloud image)
  disk {
    datastore_id = local.datastore_id
    file_id      = proxmox_virtual_environment_download_file.ubuntu_noble_cloud_image.id
    interface    = "scsi0"
    size         = local.vms.nfs_server.disk_size
    discard      = "on"
    iothread     = true
  }

  network_device {
    bridge = local.network.bridge
  }

  initialization {
    ip_config {
      ipv4 {
        address = "${local.vms.nfs_server.ip}/24"
        gateway = local.network.gateway
      }
    }
    dns {
      servers = [local.network.dns]
    }
    user_data_file_id = proxmox_virtual_environment_file.cloud_init_nfs_server.id
  }

  operating_system {
    type = "l26"
  }

  serial_device {}
}

# 2TB パススルーディスクのアタッチ (Proxmox API は root@pam のみ許可するため SSH 経由)
resource "terraform_data" "nfs_server_passthrough_disk" {
  depends_on = [proxmox_virtual_environment_vm.nfs_server]

  input = {
    vmid    = local.vms.nfs_server.vmid
    disk_id = var.nfs_passthrough_disk_id
  }

  provisioner "local-exec" {
    command = "ssh pve 'qm set ${self.input.vmid} -scsi1 /dev/disk/by-id/${self.input.disk_id}'"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "ssh pve 'qm set ${self.input.vmid} -delete scsi1' || true"
  }
}
