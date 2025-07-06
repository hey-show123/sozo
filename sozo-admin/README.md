# SoZO Admin - 管理画面

SoZO英会話学習アプリのコンテンツ管理画面です。

## 概要

この管理画面はスーパー管理者専用で、以下の機能を提供します：

- レッスンの作成・編集・削除
- コースの管理
- モジュールの管理
- 学習コンテンツの統計情報表示

## 権限

`super_admin`権限を持つユーザーのみアクセス可能です。

## セットアップ

### 1. 環境変数の設定

`.env.local`ファイルを作成し、以下の環境変数を設定してください：

```env
NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key
```

### 2. 依存関係のインストール

```bash
npm install
```

### 3. 開発サーバーの起動

```bash
npm run dev
```

### 4. super_admin権限の付与

Supabaseの管理画面で、以下のSQLを実行して特定のユーザーにsuper_admin権限を付与します：

```sql
-- ユーザーIDを確認
SELECT id, email FROM auth.users WHERE email = 'admin@example.com';

-- super_admin権限を付与（organizationは任意）
INSERT INTO user_organization_roles (user_id, organization_id, role)
VALUES ('ユーザーID', null, 'super_admin');
```

## デプロイ

Vercelへのデプロイ：

```bash
vercel
```

環境変数をVercelプロジェクトに設定することを忘れずに。

## 技術スタック

- Next.js 14 (App Router)
- TypeScript
- Tailwind CSS
- Supabase
- Lucide Icons

## ディレクトリ構造

```
app/
├── (dashboard)/      # 管理画面のページ
│   ├── lessons/     # レッスン管理
│   ├── courses/     # コース管理
│   └── modules/     # モジュール管理
├── login/           # ログインページ
└── unauthorized/    # 権限不足ページ

components/
└── layout/
    └── sidebar.tsx  # サイドバーコンポーネント

lib/
├── supabase.ts      # クライアント用Supabase
└── supabase-server.ts # サーバー用Supabase
```

## Getting Started

First, run the development server:

```bash
npm run dev
# or
yarn dev
# or
pnpm dev
# or
bun dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

You can start editing the page by modifying `app/page.tsx`. The page auto-updates as you edit the file.

This project uses [`next/font`](https://nextjs.org/docs/app/building-your-application/optimizing/fonts) to automatically optimize and load [Geist](https://vercel.com/font), a new font family for Vercel.

## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.

You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js) - your feedback and contributions are welcome!

## Deploy on Vercel

The easiest way to deploy your Next.js app is to use the [Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme) from the creators of Next.js.

Check out our [Next.js deployment documentation](https://nextjs.org/docs/app/building-your-application/deploying) for more details.
