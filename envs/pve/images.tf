resource "proxmox_virtual_environment_download_file" "ubuntu_noble_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = local.node_name

  url       = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  file_name = "noble-server-cloudimg-amd64.img"
}
