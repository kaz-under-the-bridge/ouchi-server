# IP アドレス割り当て管理表

サブネット: `192.168.1.0/24`

## 割り当て済み

| IP | ホスト名 | 用途 |
|----|----------|------|
| 192.168.1.1 | router | デフォルトゲートウェイ / DNS |
| 192.168.1.250 | pve-local | Proxmox VE ホスト |
| 192.168.1.220 | nfs-server | NFS Server (Time Machine / k8s / 共有ファイル) |
| 192.168.1.221 | ai-commander | AI Commander (Claude Code / Cursor SSH 開発環境) |
| 192.168.1.225 | reverse-proxy | リバースプロキシ (nginx + Let's Encrypt) |

## 予約

| IP | 用途 |
|----|------|
| 192.168.1.222-224 | k8s nodes (将来) |
