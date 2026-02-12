#!/bin/bash
# Proxmox ホスト上で実行し、パススルー対象の2TBディスクを特定するスクリプト
# 使い方: ssh pve < scripts/identify-passthrough-disk.sh

echo "=== ディスク一覧 (lsblk) ==="
lsblk -o NAME,SIZE,TYPE,MOUNTPOINTS,MODEL,SERIAL

echo ""
echo "=== /dev/disk/by-id/ ==="
ls -la /dev/disk/by-id/ | grep -v "part\|lvm" | grep -E "ata-|scsi-|wwn-"

echo ""
echo "=== 2TB 付近のディスク ==="
lsblk -b -o NAME,SIZE,TYPE | awk '$3=="disk" && $2 > 1500000000000 && $2 < 2500000000000 {print $1, $2/1000/1000/1000/1000 " TB"}'
