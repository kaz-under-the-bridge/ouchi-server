# AI Commander セットアップ計画

## コンセプト

**AIコマンダー・ハイブリッド構成**

- **メイン (モバイル)**: iPad/iPhone + Blink Shell → Mosh + Zellij + Claude Code で指示・レビュー
- **サブ (デスクトップ)**: PC/Mac → Cursor SSH Remote で複雑な修正・デバッグ
- Claude Code 主体で開発し、重い作業は Cursor で補完するスタイル

## セットアップ手順

### 1. セキュリティ強化 (最優先)

DDNS で外部公開するため必須。

| 項目 | 内容 |
|------|------|
| SSH 鍵認証のみ | `PasswordAuthentication no`, `PermitRootLogin no` |
| UFW ファイアウォール | SSH (22/tcp), Mosh (60000:60010/udp) のみ許可 |
| Fail2Ban | 総当たり攻撃対策 |

### 2. モダン CLI ツール群

AI に任せる開発では「コードを読む・探す」時間が長くなるため、標準ツールを置き換える。

| ツール | 用途 | 備考 |
|--------|------|------|
| `bat` | シンタックスハイライト付き cat | Claude が書いたコードの確認用 |
| `eza` | アイコン・色付き ls | apt にない場合は公式手順 |
| `ripgrep` (rg) | 超高速検索 | Claude Code が内部で使用 |
| `fd` | 高速ファイル検索 | |
| `helix` (hx) | 緊急用エディタ | 設定なしで即使える |
| `zellij` | セッション管理 | tmux 代替、Mosh と組み合わせ |

### 3. Claude Code 環境

```
fnm (Node.js バージョン管理)
  └→ Node.js LTS
       └→ @anthropic-ai/claude-code (npm global)
```

- ヘッドレス認証: `claude login` → 表示された URL をブラウザで開く → 認証コードを貼り付け
- トークン保存先: `~/.anthropic/`

### 4. クライアント側接続設定

#### A. モバイル (Blink Shell → Mosh)

```
接続 → zellij a -c mobile → claude "指示内容"
```

- Mosh: 不安定な回線でもセッション維持
- Zellij: デタッチ/アタッチでシームレスに作業継続

#### B. デスクトップ (Cursor SSH Remote)

```
~/.ssh/config:
  Host ai-commander
    HostName <DDNS or 192.168.1.221>
    User ubuntu
    IdentityFile ~/.ssh/id_rsa
```

- Cursor の「Remote - SSH」拡張で接続
- GUI でファイル操作、デバッガ利用可能

## ワークフロー

### 外出先 (iPad + Blink + Mosh)

1. Zellij に接続
2. `claude "機能Aの実装をお願い。仕様は〜"` で指示
3. `bat src/feature_a.ts` で確認、`git diff` で差分チェック
4. 問題なければ commit & push
5. 複雑な問題は中断 (Zellij デタッチ)、帰宅後に対応

### 帰宅後 (PC + Cursor)

1. Cursor で SSH 接続
2. GUI でファイルを開き、Cursor 内蔵 AI と対話しながら解決
3. デバッガで深いロジックを追跡

## Zellij レイアウト (推奨)

- **上段 (70%)**: メインターミナル (Claude Code)
- **下段 (30%)**: ログ監視 / Git 操作

「常に Claude の作業を見守りながら、下で Git 操作やファイル確認をする」司令塔スタイル。

## 構築順序

1. セキュリティ強化 (SSH, UFW, Fail2Ban)
2. CLI ツール群のインストール
3. Claude Code 環境構築
4. Zellij 設定
5. クライアント側 SSH 設定
6. DDNS 設定 (外部アクセス用)
