-- auth拡張機能の有効化
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE SCHEMA IF NOT EXISTS auth;
GRANT USAGE ON SCHEMA auth TO postgres, anon, authenticated, service_role;

-- auth.uid()関数の作成
CREATE OR REPLACE FUNCTION auth.uid() 
RETURNS uuid 
LANGUAGE sql STABLE
AS $$
  SELECT coalesce(
    current_setting('request.jwt.claim.sub', true),
    (current_setting('request.jwt.claims', true)::jsonb ->> 'sub')
  )::uuid
$$;

-- 公開可能なプロジェクトを表示するビュー
CREATE VIEW public_projects AS
SELECT 
    p.*,
    u.nickname as creator_nickname,
    u.profile_image_url as creator_profile_image
FROM projects p
JOIN users u ON p.creator_id = u.id
WHERE p.status = 'active' 
AND p.office_status = 'approved';

-- ユーザーが閲覧可能なプロジェクトを表示するビュー
CREATE VIEW user_accessible_projects AS
SELECT 
    p.*,
    u.nickname as creator_nickname,
    u.profile_image_url as creator_profile_image,
    CASE 
        WHEN p.creator_id = auth.uid() THEN true
        WHEN p.status = 'active' AND p.office_status = 'approved' THEN true
        ELSE false
    END as is_accessible
FROM projects p
JOIN users u ON p.creator_id = u.id; 