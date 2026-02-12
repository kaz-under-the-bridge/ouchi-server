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
