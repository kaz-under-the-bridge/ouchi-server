provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  insecure  = true

  ssh {
    agent    = true
    username = "root"

    node {
      name    = "pve"
      address = "pve-local.under-the-bridge.co.jp"
    }
  }
}
