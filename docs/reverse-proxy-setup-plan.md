# Plan: リバースプロキシ専用 VM + Let's Encrypt ワイルドカード証明書（サブドメインベース）

## Context

OpenClaw Dashboard は LAN バインドで HTTPS が必要。今後のサービス追加も見据えて、**リバースプロキシ専用 VM** を Proxmox に立て、TLS 終端 + サブドメインベースルーティングを一元管理する。ワイルドカード証明書 (`*.under-the-bridge.co.jp`) で全サブドメインをカバー。

## ドメイン命名規則

- `xxx-local.under-the-bridge.co.jp` → LAN 内専用（A レコード = private IP）
- `xxx.under-the-bridge.co.jp` → 外部公開用（将来）
- サービス名を推測されにくい短縮名にする（openclaw → oc）

## アーキテクチャ

```
ブラウザ (Mac/iPad)
    │
    │ https://oc-local.under-the-bridge.co.jp
    ▼
┌───────────────────────────────────────────────────┐
│ reverse-proxy (192.168.1.225)                     │
│ nginx + certbot (DNS-01 / Cloudflare)             │
│ *.under-the-bridge.co.jp ワイルドカード証明書      │
│                                                   │
│ server_name oc-local.xxx → 192.168.1.221:18789    │  ← OpenClaw
│ server_name xxx-local.xxx → 192.168.1.xxx:xxxx    │  ← 将来のサービス
└───────────────────────────────────────────────────┘
```

## 実装ステップ

### Step 1: Proxmox に VM 作成（手動）

- Ubuntu 24.04 VM、IP: `192.168.1.225`、ホスト名: `reverse-proxy`
- 最小スペック: 1 vCPU / 1GB RAM / 10GB disk

### Step 2: ドキュメント・Ansible inventory 更新

**変更ファイル:**
- `docs/ip-allocation.md` — 192.168.1.225 追加
- `ansible/inventory/hosts.yml` — `reverse_proxies` グループ追加
- `docs/remote-access.md` — reverse-proxy の SSH 設定追加

### Step 3: Ansible ロール `certbot_cloudflare` を作成

```
ansible/roles/certbot_cloudflare/
├── tasks/main.yml
├── defaults/main.yml
├── handlers/main.yml
└── templates/
    └── cloudflare.ini.j2
```

- certbot + python3-certbot-dns-cloudflare インストール
- Cloudflare API トークン配置 (chmod 600)
- `certbot certonly --dns-cloudflare -d "*.under-the-bridge.co.jp" -d "under-the-bridge.co.jp"`
- certbot renew 時に nginx reload する deploy hook 設定

### Step 4: Ansible ロール `nginx_proxy` を作成

```
ansible/roles/nginx_proxy/
├── tasks/main.yml
├── defaults/main.yml
├── handlers/main.yml
└── templates/
    ├── default.conf.j2          # HTTP→HTTPS リダイレクト + デフォルト 444
    └── proxy-backend.conf.j2    # サブドメイン別 server ブロック
```

openclaw の server ブロック例:
```nginx
server {
    listen 443 ssl;
    server_name oc-local.under-the-bridge.co.jp;

    ssl_certificate     /etc/letsencrypt/live/under-the-bridge.co.jp/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/under-the-bridge.co.jp/privkey.pem;

    location / {
        proxy_pass http://192.168.1.221:18789;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

サービス追加時は `nginx_proxy_backends` リストにエントリを追加するだけ。

### Step 5: `group_vars/reverse_proxies.yml` 作成

```yaml
ufw_allowed_ports:
  - { port: "22", proto: "tcp" }
  - { port: "80", proto: "tcp" }
  - { port: "443", proto: "tcp" }

certbot_domain: "under-the-bridge.co.jp"
certbot_email: "kaz@under-the-bridge.work"
certbot_cloudflare_api_token: "{{ vault_cloudflare_api_token }}"

nginx_proxy_backends:
  - name: openclaw
    server_name: oc-local.under-the-bridge.co.jp
    backend: "http://192.168.1.221:18789"
```

### Step 6: site.yml に追加

```yaml
- name: Reverse Proxy 構成
  hosts: reverse_proxies
  roles:
    - certbot_cloudflare
    - nginx_proxy
```

### Step 7: Cloudflare DNS 設定

- `oc-local.under-the-bridge.co.jp` → A レコード `192.168.1.225`（Proxy OFF、LAN 内のみ解決）
- 将来のサービスも `xxx-local.under-the-bridge.co.jp` → `192.168.1.225` で追加

### Step 8: Vault に Cloudflare API トークン追加

```bash
cd ansible && ansible-vault edit group_vars/all/vault.yml
# vault_cloudflare_api_token: "your-token-here" を追加
```

## 必要な事前準備（手動）

1. Proxmox で VM 作成 (192.168.1.225, Ubuntu 24.04, 1 vCPU / 1GB RAM / 10GB disk)
2. Cloudflare で API トークン取得（Zone:DNS:Edit 権限）
3. Cloudflare DNS に A レコード追加: `oc-local.under-the-bridge.co.jp` → `192.168.1.225`（Proxy OFF）
4. Vault に Cloudflare API トークン追加（上記 Step 8 参照）

## 対象ファイル

- **新規**: `ansible/roles/certbot_cloudflare/` (tasks, defaults, handlers, templates)
- **新規**: `ansible/roles/nginx_proxy/` (tasks, defaults, handlers, templates)
- **新規**: `ansible/group_vars/reverse_proxies.yml`
- **新規**: `ansible/playbooks/reverse-proxy.yml`
- **変更**: `ansible/inventory/hosts.yml`
- **変更**: `ansible/site.yml`
- **変更**: `ansible/Makefile`
- **変更**: `ansible/group_vars/all/vault.yml`
- **変更**: `docs/ip-allocation.md`

## 進捗

| ステップ | 状態 | 備考 |
|----------|------|------|
| Step 1: Proxmox VM 作成 | 未着手 | 手動作業 |
| Step 2: ドキュメント・inventory 更新 | **完了** | `docs/ip-allocation.md`, `ansible/inventory/hosts.yml` |
| Step 3: `certbot_cloudflare` ロール | **完了** | tasks, defaults, handlers, templates |
| Step 4: `nginx_proxy` ロール | **完了** | tasks, defaults, handlers, templates (SSL 共通設定含む) |
| Step 5: `group_vars/reverse_proxies.yml` | **完了** | UFW, certbot, バックエンド定義 |
| Step 6: `site.yml` + Makefile 更新 | **完了** | `make proxy` ターゲット追加、個別 playbook 作成 |
| Step 7: Cloudflare DNS 設定 | 未着手 | 手動作業 |
| Step 8: Vault に API トークン追加 | 未着手 | `ansible-vault edit` で手動追加 |

## 検証

1. `make all` で Ansible 適用
2. `ssh reverse-proxy 'certbot certificates'` で証明書確認
3. `https://oc-local.under-the-bridge.co.jp/` でダッシュボードが開く（証明書警告なし）
4. Slack 経由の OpenClaw 応答が動作
5. `ssh reverse-proxy 'certbot renew --dry-run'` で自動更新テスト
