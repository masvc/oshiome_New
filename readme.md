# 推しおめ (Oshiome) 2.0

## サービス概要

推し（Vtuber、アイドル等）の誕生日を祝うためのクラウドファンディングプラットフォーム。
ファンが連携して駅広告やデジタルサイネージなどにお誕生日広告を出すことのできるサービス。

## 技術スタック

### フロントエンド
- Next.js 14
- TypeScript
- TailwindCSS

### バックエンド
- Supabase
- PostgreSQL

### インフラ
- Vercel (フロントエンド)
- Supabase (バックエンド)

### 品質管理
- ESLint
- Prettier

## 開発フロー

### ブランチ戦略
- `main`: 本番環境
- `develop`: 開発環境
- Feature branches: `feature/*`

### 基本的なテスト
- ユニットテスト
- 動作確認テスト

## セットアップ手順

### 開発環境のセットアップ

1. リポジトリのクローン
```bash
git clone https://github.com/masvc/oshiome_New.git
cd oshiome_new
```

2. 依存関係のインストール
```bash
npm install
```

3. 環境変数の設定
```bash
cp .env.example .env
# .envファイルを編集して必要な環境変数を設定
```

4. 開発サーバーの起動
```bash
# Dockerを使用する場合
npm run docker:dev

# ローカルで実行する場合
npm run dev
```

### テストの実行

```bash
# ユニットテスト
npm run test

# 監視モードでテストを実行
npm run test:watch
```

### コード品質チェック

```bash
# リントとフォーマット
npm run lint
npm run format

# 型チェック
npm run type-check
```

## デプロイメント

### Vercelへのデプロイ

1. GitHubリポジトリとVercelプロジェクトの連携
2. 環境変数の設定
3. デプロイ設定の確認
   - 本番ブランチ（`main`）の設定
   - ビルドコマンドの確認
   - 出力ディレクトリの確認
4. プレビューデプロイの確認（プルリクエスト時）
5. 本番環境への自動デプロイ（mainブランチへのマージ時）

### Dockerでの本番環境デプロイ

```bash
# 本番用イメージのビルド
npm run docker:build

# 本番用コンテナの起動
npm run docker:prod
```

## 基本的なセキュリティ要件

### 1. ユーザー認証 🔐
- NextAuth.js による認証
  - Xアカウントでログイン
  - メールアドレス/パスワード認証
- 権限管理
  - 一般ユーザー
    - クラウドファンディングへの支援参加
    - 企画の閲覧
    - プロフィール管理
  - 企画者
    - プロジェクト管理
      - 企画の作成と申請
      - 企画内容の編集
      - 広告データのアップロード
    - プロジェクト分析
      - 支援状況の確認
      - 支援者データの確認
      - 目標達成率の確認
    - 支援者とのコミュニケーション
      - お知らせ投稿
      - コメント対応
  - 管理者（アドミン）
    - プロジェクト管理
      - 申請された企画の承認/非承認
      - 不適切な企画の停止
      - 全プロジェクトの進捗確認
    - サービス分析
      - 全体の支援状況
      - ユーザー数の推移
      - カテゴリー別の集計
    - ユーザー管理
      - アカウントの停止/復帰
      - 権限の変更
    - 売上管理
      - 売上レポート
      - 支払い状況の確認

### 2. データ保護 🛡️
- パスワードのハッシュ化
- 環境変数での機密情報管理
- プライバシーポリシー・利用規約

### 3. 決済セキュリティ 💳
- Stripeによる決済処理
- 取引履歴の保存

### 4. 基本的な安全対策 🌐
- SSL/TLS証明書の導入
- 入力値の検証
- エラーメッセージの適切な表示

## 開発時のチェックリスト ✅

### コーディング時
- [ ] パスワードやAPIキーは環境変数で管理
- [ ] ユーザー入力値のチェック
- [ ] エラーメッセージは詳細を隠す

### デプロイ前
- [ ] 環境変数の設定
- [ ] SSL/TLS証明書の確認
- [ ] 動作テスト

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。

## 実装順序チェックリスト

### 1. 基盤構築フェーズ
- [x] GitHubリポジトリの設定
  - [x] .gitignoreの設定
  - [x] ブランチ戦略の確立
  - [x] コミットメッセージ規約の設定
- [x] Docker環境の構築
  - [x] 開発環境用Dockerfile
  - [x] docker-compose.yml
  - [x] 本番環境用Dockerfile
- [x] 開発環境の整備
  - [x] ESLint, Prettierの設定
  - [x] 開発用スクリプトの整備
  - [x] 環境変数の管理方法の確立

### 2. インフラ構築フェーズ
- [x] Supabaseのセットアップ
  - [x] データベース設計
  - [x] Supabaseプロジェクトの作成
  - [x] 環境変数の設定
  - [x] 認証システムの構築
  - [ ] バックアップ戦略の確立
- [ ] Vercelの設定
  - [ ] GitHubとの連携設定
  - [ ] 開発/本番環境の設定
  - [ ] 環境変数の設定
  - [ ] ドメイン設定
  - [ ] 自動デプロイの確認

### 3. バックエンド開発フェーズ
- [x] 認証システムの実装
  - [x] Supabase Authの設定
  - [x] ログイン/登録機能
  - [x] X認証の連携
  - [ ] 権限管理
- [ ] データベース操作の実装
  - [ ] プロジェクトCRUD
  - [ ] ユーザー管理
  - [ ] 支援管理
- [ ] API実装
  - [ ] RESTful API設計
  - [ ] エンドポイント実装
  - [ ] バリデーション

### 4. フロントエンド開発フェーズ
- [ ] 基本コンポーネントの実装
  - [ ] レイアウト
  - [ ] 共通UI
  - [ ] フォーム
- [ ] ページ実装
  - [ ] トップページ
  - [ ] プロジェクト一覧
  - [ ] プロジェクト詳細
  - [ ] ユーザープロフィール
- [ ] 状態管理の実装
  - [ ] グローバル状態
  - [ ] キャッシュ戦略
- [ ] UI/UXの改善
  - [ ] レスポンシブ対応
  - [ ] アニメーション
  - [ ] エラーハンドリング

### 5. 決済システム実装
- [ ] Stripe連携
  - [ ] 支払いフロー
  - [ ] サブスクリプション
  - [ ] 請求管理
- [ ] 決済関連UI
  - [ ] 支払いフォーム
  - [ ] 支払い履歴
  - [ ] 請求書

### 6. セキュリティ強化
- [ ] セキュリティ対策
  - [ ] XSS対策
  - [ ] CSRF対策
  - [ ] SQLインジェクション対策
- [ ] パフォーマンス最適化
  - [ ] 画像最適化
  - [ ] バンドルサイズ最適化
  - [ ] キャッシュ戦略

### 7. テスト・ドキュメント
- [ ] テスト実装
  - [x] ユニットテスト
  - [ ] 統合テスト
  - [ ] E2Eテスト
- [ ] ドキュメント作成
  - [ ] API仕様書
  - [ ] セットアップガイド
  - [ ] 運用マニュアル

### 8. 本番環境リリース
- [ ] 最終確認
  - [ ] セキュリティチェック
  - [ ] パフォーマンステスト
  - [ ] ユーザビリティテスト
- [ ] 本番デプロイ
  - [ ] データ移行
  - [ ] 監視設定
  - [ ] バックアップ設定
