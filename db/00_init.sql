-- データベースの初期化
DROP TABLE IF EXISTS project_supports;
DROP TABLE IF EXISTS project_likes;
DROP TABLE IF EXISTS user_social_links;
DROP TABLE IF EXISTS projects;
DROP TABLE IF EXISTS users;

-- 拡張機能の追加
CREATE EXTENSION IF NOT EXISTS "uuid-ossp"; 