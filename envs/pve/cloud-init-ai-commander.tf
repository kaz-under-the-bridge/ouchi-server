resource "proxmox_virtual_environment_file" "cloud_init_ai_commander" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = local.node_name

  source_raw {
    data = <<-EOF
      #cloud-config
      hostname: ${local.vms.ai_commander.name}
      fqdn: ${local.vms.ai_commander.name}.local
      timezone: Asia/Tokyo

      users:
        - name: ubuntu
          groups: [adm, sudo]
          shell: /bin/bash
          sudo: ALL=(ALL) NOPASSWD:ALL
          ssh_authorized_keys:
            - ${var.ssh_public_key}

      package_update: true
      packages:
        - qemu-guest-agent
        - curl
        - git
        - build-essential
        - jq
        - unzip

      runcmd:
        - systemctl enable --now qemu-guest-agent
    EOF

    file_name = "cloud-init-ai-commander.yaml"
  }
}
