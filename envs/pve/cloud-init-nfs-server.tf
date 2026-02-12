resource "proxmox_virtual_environment_file" "cloud_init_nfs_server" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = local.node_name

  source_raw {
    data = <<-EOF
      #cloud-config
      hostname: ${local.vms.nfs_server.name}
      fqdn: ${local.vms.nfs_server.name}.local
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
        - nfs-kernel-server

      runcmd:
        # qemu-guest-agent 起動
        - systemctl enable --now qemu-guest-agent

        # 2TB ディスク (scsi1 = /dev/sdb) のフォーマットとマウント
        - |
          if ! blkid /dev/sdb1; then
            parted /dev/sdb --script mklabel gpt
            parted /dev/sdb --script mkpart primary ext4 0% 100%
            partprobe /dev/sdb
            sleep 2
            mkfs.ext4 -L nfs-data /dev/sdb1
          fi
        - mkdir -p /srv/nfs
        - echo 'LABEL=nfs-data /srv/nfs ext4 defaults,nofail 0 2' >> /etc/fstab
        - mount -a

        # NFS ディレクトリ構造
        - mkdir -p /srv/nfs/timemachine
        - mkdir -p /srv/nfs/k8s
        - mkdir -p /srv/nfs/shared
        - chown -R nobody:nogroup /srv/nfs

        # NFS export 設定
        - echo '/srv/nfs 192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash)' >> /etc/exports
        - exportfs -ra
        - systemctl enable --now nfs-kernel-server
    EOF

    file_name = "cloud-init-nfs-server.yaml"
  }
}
