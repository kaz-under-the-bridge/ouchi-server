# リモート接続手順

AI Commander (192.168.1.221) への接続方法をまとめたドキュメント。

## 前提条件

- SSH 公開鍵が `kaz` ユーザーの `authorized_keys` に登録済み
- Ansible で構成適用済み (`make all`)

## SSH config

`~/.ssh/config` に以下を追加:

```
Host ai-commander
    HostName 192.168.1.221
    User kaz
    IdentityFile ~/.ssh/id_rsa

Host nfs-server
    HostName 192.168.1.220
    User ubuntu
    IdentityFile ~/.ssh/id_rsa
```

## 接続方法

### LAN 内 SSH

```bash
ssh ai-commander
# または
ssh kaz@192.168.1.221
```

### Mosh (モバイル向け・接続断に強い)

```bash
mosh ai-commander
# または
mosh kaz@192.168.1.221
```

Mosh は UDP 60000-60010 を使用。UFW で許可済み。

### Cursor SSH Remote

1. Cursor で `Cmd+Shift+P` → **Remote-SSH: Connect to Host**
2. `ai-commander` を選択
3. 初回は Remote Server のインストールが自動実行される

### Blink Shell (iPad / iPhone)

1. Blink Shell を開く
2. `Settings` → `Keys` で SSH 秘密鍵をインポート
3. `Settings` → `Hosts` で新規ホスト追加:
   - Host: `ai-commander`
   - Hostname: `192.168.1.221`
   - User: `kaz`
   - Key: インポートした鍵を選択
   - Mosh: ON
4. ターミナルで `mosh ai-commander` を実行

## Zellij セッション管理

Mosh や SSH で接続後、Zellij でセッションを管理:

```bash
# セッションの作成・アタッチ (存在しなければ作成)
zellij a -c main

# モバイル用セッション
zellij a -c mobile

# セッション一覧
zellij ls

# デタッチ
Ctrl+o, d
```

## Claude Code

### 認証 (初回のみ・手動)

```bash
ssh ai-commander
~/.local/bin/claude login
# → 表示された URL をブラウザで開いて認証
```

### 使用

```bash
claude          # 対話モード
claude "指示"   # ワンショット
```

## トラブルシューティング

### SSH 接続できない

```bash
# 1. ネットワーク疎通確認
ping 192.168.1.221

# 2. SSH デバッグモード
ssh -vvv kaz@192.168.1.221

# 3. VM が起動しているか確認 (Proxmox)
ssh pve 'qm status 201'
```

### Mosh 接続できない

```bash
# UFW でポートが開いているか確認
ssh ai-commander 'sudo ufw status' | grep 60000

# mosh-server がインストールされているか確認
ssh ai-commander 'which mosh-server'
```

### NFS マウントされていない

```bash
# マウント状態確認
ssh ai-commander 'df -h /home/kaz/git'

# 手動マウント
ssh ai-commander 'sudo mount -a'

# NFS Server 側の export 確認
showmount -e 192.168.1.220
```
