output "proxmox_version" {
  description = "Proxmox VE のバージョン情報"
  value       = data.proxmox_virtual_environment_version.current.version
}

output "proxmox_nodes" {
  description = "Proxmox クラスタのノード一覧"
  value       = data.proxmox_virtual_environment_nodes.all.names
}
