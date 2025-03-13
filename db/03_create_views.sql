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
        WHEN p.creator_id = current_user_id THEN true
        WHEN p.status = 'active' AND p.office_status = 'approved' THEN true
        ELSE false
    END as is_accessible
FROM projects p
JOIN users u ON p.creator_id = u.id; 