# ouchi-server

自宅サーバー (Proxmox VE) の構成を Terraform でコード管理するリポジトリ。

## インフラ構成

**Proxmox VE ホスト**: `pve-local` (192.168.1.250) — Proxmox VE 9.1.1

### VM 一覧

| VM | VMID | IP | スペック | 用途 |
|----|------|----|----------|------|
| nfs-server | 200 | 192.168.1.220 | 2 core / 2 GB / 20 GB + 2 TB passthrough | NFS (Time Machine / k8s provisioner / 共有ファイル) |
| ai-commander | 201 | 192.168.1.221 | 4 core / 12 GB / 50 GB | Claude Code / Cursor SSH 開発環境 |

### NFS エクスポート

| パス | 用途 |
|------|------|
| `/srv/nfs/timemachine` | macOS Time Machine バックアップ |
| `/srv/nfs/k8s` | k8s NFS provisioner |
| `/srv/nfs/shared` | 共有ファイル |

IP 割り当ての詳細は [docs/ip-allocation.md](docs/ip-allocation.md) を参照。

## ディレクトリ構成

```
envs/pve/              # Proxmox VE 環境の Terraform 定義
  ├── provider.tf      #   プロバイダ・SSH 設定
  ├── locals.tf        #   共通設定 (ノード名, ネットワーク, VM定義)
  ├── variables.tf     #   入力変数
  ├── images.tf        #   Ubuntu cloud image
  ├── cloud-init-*.tf  #   VM 別 cloud-init snippet
  ├── vm-*.tf          #   VM 定義
  └── outputs.tf       #   出力定義
scripts/               # セットアップ用スクリプト
docs/                  # ドキュメント
.github/workflows/     # CI/CD (GitHub Actions)
```

## 前提条件

- Terraform >= 1.5.0
- Proxmox VE 9.x
- AWS CLI (S3 バックエンド用)
- Proxmox ホストへの SSH 接続 (`ssh pve`)

## セットアップ

```bash
# 1. Proxmox API トークン作成
ssh pve < scripts/setup-proxmox-terraform.sh

# 2. Proxmox の local ストレージで Snippets を有効化
ssh pve "pvesm set local --content iso,vztmpl,backup,import,snippets"

# 3. パススルーディスクの特定
ssh pve < scripts/identify-passthrough-disk.sh

# 4. terraform.tfvars 設定
cp envs/pve/terraform.tfvars.example envs/pve/terraform.tfvars
# → API トークン、SSH 公開鍵、ディスク ID を記入

# 5. 初期化・デプロイ
cd envs/pve
terraform init
terraform plan
terraform apply
```

## 接続

```bash
ssh ubuntu@192.168.1.220  # nfs-server
ssh ubuntu@192.168.1.221  # ai-commander
```

## 技術スタック

- [bpg/proxmox](https://registry.terraform.io/providers/bpg/proxmox/latest) ~> 0.95
- Backend: S3
- OS: Ubuntu 24.04 LTS (cloud image)

## 注意事項

- 2TB ディスクパススルーは Proxmox API の制約で `root@pam` のみ許可のため、`terraform_data` + SSH (`qm set`) で実装
- cloud-init の `user_data_file_id` と `user_account` ブロックは排他的（SSH 鍵は cloud-init YAML 内で設定）
