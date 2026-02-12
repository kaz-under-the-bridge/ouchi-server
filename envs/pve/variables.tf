variable "proxmox_endpoint" {
  description = "Proxmox VE API のエンドポイント URL"
  type        = string
  default     = "https://pve-local.under-the-bridge.co.jp:8006"
}

variable "proxmox_api_token" {
  description = "Proxmox VE API トークン (例: terraform@pve!provider=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "VM に配置する SSH 公開鍵"
  type        = string
  sensitive   = true
}

variable "network_gateway" {
  description = "ネットワークのデフォルトゲートウェイ"
  type        = string
  default     = "192.168.1.1"
}

variable "network_dns" {
  description = "DNS サーバーアドレス"
  type        = string
  default     = "192.168.1.1"
}

variable "nfs_passthrough_disk_id" {
  description = "NFS サーバーにパススルーする 2TB ディスクの /dev/disk/by-id/ パス (例: ata-ST2000DM008-XXXXXX)"
  type        = string
}
