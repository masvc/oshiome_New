-- プロジェクトの期限切れをチェックする関数
CREATE OR REPLACE FUNCTION check_project_end_date()
RETURNS void AS $$
BEGIN
    -- 期限切れのプロジェクトを終了状態に更新
    UPDATE projects
    SET 
        status = 'ended',
        updated_at = CURRENT_TIMESTAMP
    WHERE status = 'active'
    AND end_date <= CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql;

-- プロジェクトの集計情報を取得する関数
CREATE OR REPLACE FUNCTION get_project_stats(project_id UUID)
RETURNS TABLE (
    like_count BIGINT,
    supporter_count BIGINT,
    total_amount BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (SELECT COUNT(*) FROM project_likes WHERE project_id = $1) as like_count,
        (SELECT COUNT(*) FROM project_supports WHERE project_id = $1) as supporter_count,
        (SELECT COALESCE(SUM(amount), 0) FROM project_supports WHERE project_id = $1) as total_amount;
END;
$$ LANGUAGE plpgsql;

-- プロジェクト一覧用のビュー（集計情報付き）
CREATE OR REPLACE VIEW project_list_view AS
SELECT 
    p.*,
    u.nickname as creator_nickname,
    u.profile_image_url as creator_profile_image,
    (SELECT COUNT(*) FROM project_likes WHERE project_id = p.id) as like_count,
    (SELECT COUNT(*) FROM project_supports WHERE project_id = p.id) as supporter_count,
    CASE 
        WHEN p.creator_id = auth.uid() THEN true
        WHEN p.status = 'active' AND p.office_status = 'approved' THEN true
        ELSE false
    END as is_accessible
FROM projects p
JOIN users u ON p.creator_id = u.id; 