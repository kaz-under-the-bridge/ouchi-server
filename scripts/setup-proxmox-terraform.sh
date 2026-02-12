#!/bin/bash
# Proxmox VE に Terraform 用の API トークンをセットアップするスクリプト
# 使い方: ssh pve < scripts/setup-proxmox-terraform.sh
set -euo pipefail

ROLE_NAME="TerraformAdmin"
USER_NAME="terraform@pve"
TOKEN_ID="provider"

echo "=== Proxmox Terraform セットアップ ==="

# 1. TerraformAdmin ロール作成
echo "[1/3] ロール '${ROLE_NAME}' を作成..."
PRIVS="Datastore.Allocate,Datastore.AllocateSpace,Datastore.AllocateTemplate,Datastore.Audit"
PRIVS="${PRIVS},Group.Allocate,Mapping.Audit,Mapping.Use"
PRIVS="${PRIVS},Pool.Allocate,Pool.Audit"
PRIVS="${PRIVS},Realm.AllocateUser"
PRIVS="${PRIVS},SDN.Allocate,SDN.Audit,SDN.Use"
PRIVS="${PRIVS},Sys.Audit,Sys.Console,Sys.Syslog"
PRIVS="${PRIVS},User.Modify"
PRIVS="${PRIVS},VM.Allocate,VM.Audit,VM.Backup,VM.Clone"
PRIVS="${PRIVS},VM.Config.CDROM,VM.Config.CPU,VM.Config.Cloudinit"
PRIVS="${PRIVS},VM.Config.Disk,VM.Config.HWType,VM.Config.Memory"
PRIVS="${PRIVS},VM.Config.Network,VM.Config.Options"
PRIVS="${PRIVS},VM.Console,VM.Migrate,VM.PowerMgmt"
PRIVS="${PRIVS},VM.Replicate,VM.Snapshot,VM.Snapshot.Rollback"

if pveum role add "${ROLE_NAME}" -privs "${PRIVS}" 2>&1; then
  echo "  -> ロール作成完了"
else
  echo "  -> ロールは既に存在します（スキップ）"
fi

# 2. terraform@pve ユーザー作成
echo "[2/3] ユーザー '${USER_NAME}' を作成..."
pveum user add "${USER_NAME}" -comment "Terraform automation user" \
  2>/dev/null || echo "  -> ユーザーは既に存在します（スキップ）"

# ロールをユーザーに割り当て（パス / = 全リソース）
pveum aclmod / -user "${USER_NAME}" -role "${ROLE_NAME}"

# 3. API トークン作成 (privsep=0: ユーザーと同じ権限を継承)
echo "[3/3] API トークン '${TOKEN_ID}' を作成..."
pveum user token add "${USER_NAME}" "${TOKEN_ID}" --privsep 0 2>/dev/null \
  || echo "  -> トークンは既に存在します（再作成する場合は先に削除してください）"

echo ""
echo "=== セットアップ完了 ==="
echo "terraform.tfvars に以下の形式で記入してください:"
echo '  proxmox_api_token = "terraform@pve!provider=<上記で表示されたトークン値>"'
