output "proxmox_version" {
  description = "Proxmox VE のバージョン情報"
  value       = data.proxmox_virtual_environment_version.current.version
}

output "proxmox_nodes" {
  description = "Proxmox クラスタのノード一覧"
  value       = data.proxmox_virtual_environment_nodes.all.names
}

output "vm_summary" {
  description = "作成した VM のサマリー"
  value = {
    nfs_server = {
      name = proxmox_virtual_environment_vm.nfs_server.name
      vmid = proxmox_virtual_environment_vm.nfs_server.vm_id
      ip   = local.vms.nfs_server.ip
    }
    ai_commander = {
      name = proxmox_virtual_environment_vm.ai_commander.name
      vmid = proxmox_virtual_environment_vm.ai_commander.vm_id
      ip   = local.vms.ai_commander.ip
    }
  }
}
