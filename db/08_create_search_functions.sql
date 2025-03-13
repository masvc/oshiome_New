-- プロジェクト検索用の関数
CREATE OR REPLACE FUNCTION search_projects(
    search_query TEXT,
    sort_by TEXT DEFAULT 'created_at',
    sort_order TEXT DEFAULT 'DESC'
)
RETURNS TABLE (
    id UUID,
    title TEXT,
    description TEXT,
    target_amount INTEGER,
    current_amount INTEGER,
    start_date TIMESTAMP WITH TIME ZONE,
    end_date TIMESTAMP WITH TIME ZONE,
    creator_nickname TEXT,
    creator_profile_image TEXT,
    like_count BIGINT,
    supporter_count BIGINT,
    days_remaining INTEGER,
    status TEXT,
    office_status TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.title,
        p.description,
        p.target_amount,
        p.current_amount,
        p.start_date,
        p.end_date,
        u.nickname as creator_nickname,
        u.profile_image_url as creator_profile_image,
        psc.like_count,
        psc.supporter_count,
        psc.days_remaining,
        p.status,
        p.office_status
    FROM projects p
    JOIN users u ON p.creator_id = u.id
    JOIN project_stats_cache psc ON p.id = psc.project_id
    WHERE 
        p.status = 'active' 
        AND p.office_status = 'approved'
        AND (
            LOWER(p.title) LIKE LOWER('%' || search_query || '%')
            OR LOWER(p.description) LIKE LOWER('%' || search_query || '%')
            OR LOWER(u.nickname) LIKE LOWER('%' || search_query || '%')
        )
    ORDER BY
        CASE 
            WHEN sort_by = 'created_at' THEN p.created_at::TEXT
            WHEN sort_by = 'total_amount' THEN psc.total_amount::TEXT
            WHEN sort_by = 'like_count' THEN psc.like_count::TEXT
            WHEN sort_by = 'days_remaining' THEN psc.days_remaining::TEXT
            ELSE p.created_at::TEXT
        END DESC;
END;
$$ LANGUAGE plpgsql;

-- プロジェクト一覧取得用の関数（ソート機能付き）
CREATE OR REPLACE FUNCTION get_projects(
    sort_by TEXT DEFAULT 'created_at',
    sort_order TEXT DEFAULT 'DESC',
    limit_count INTEGER DEFAULT 20,
    offset_count INTEGER DEFAULT 0
)
RETURNS TABLE (
    id UUID,
    title TEXT,
    description TEXT,
    target_amount INTEGER,
    current_amount INTEGER,
    start_date TIMESTAMP WITH TIME ZONE,
    end_date TIMESTAMP WITH TIME ZONE,
    creator_nickname TEXT,
    creator_profile_image TEXT,
    like_count BIGINT,
    supporter_count BIGINT,
    days_remaining INTEGER,
    status TEXT,
    office_status TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.title,
        p.description,
        p.target_amount,
        p.current_amount,
        p.start_date,
        p.end_date,
        u.nickname as creator_nickname,
        u.profile_image_url as creator_profile_image,
        psc.like_count,
        psc.supporter_count,
        psc.days_remaining,
        p.status,
        p.office_status
    FROM projects p
    JOIN users u ON p.creator_id = u.id
    JOIN project_stats_cache psc ON p.id = psc.project_id
    WHERE 
        p.status = 'active' 
        AND p.office_status = 'approved'
    ORDER BY
        CASE 
            WHEN sort_by = 'created_at' THEN p.created_at::TEXT
            WHEN sort_by = 'total_amount' THEN psc.total_amount::TEXT
            WHEN sort_by = 'like_count' THEN psc.like_count::TEXT
            WHEN sort_by = 'days_remaining' THEN psc.days_remaining::TEXT
            ELSE p.created_at::TEXT
        END DESC
    LIMIT limit_count
    OFFSET offset_count;
END;
$$ LANGUAGE plpgsql; 