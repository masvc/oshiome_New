-- 既存の関数を削除
DROP FUNCTION IF EXISTS search_projects(text, text, text);
DROP FUNCTION IF EXISTS search_projects_by_title(text);
DROP FUNCTION IF EXISTS search_projects_by_description(text);
DROP FUNCTION IF EXISTS search_projects_by_idol_name(text);
DROP FUNCTION IF EXISTS get_projects(text, text, integer, integer);

-- 以降の関数作成のSQLを実行

-- プロジェクト検索用の関数（エラー処理付き）
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
    created_at TIMESTAMP WITH TIME ZONE,
    creator_nickname TEXT,
    creator_profile_image TEXT,
    like_count BIGINT,
    supporter_count BIGINT,
    days_remaining INTEGER,
    status TEXT,
    office_status TEXT,
    total_count BIGINT
) AS $$
DECLARE
    valid_sort_columns TEXT[] := ARRAY['created_at', 'current_amount', 'like_count', 'days_remaining'];
    valid_sort_orders TEXT[] := ARRAY['ASC', 'DESC'];
BEGIN
    -- ソート条件の検証
    IF sort_by != ALL(valid_sort_columns) THEN
        RAISE EXCEPTION '無効なソート条件です。有効な値: %', valid_sort_columns;
    END IF;

    IF sort_order != ALL(valid_sort_orders) THEN
        RAISE EXCEPTION '無効なソート順序です。有効な値: %', valid_sort_orders;
    END IF;

    -- 検索クエリの検証
    IF search_query IS NULL OR TRIM(search_query) = '' THEN
        RAISE EXCEPTION '検索キーワードを入力してください。';
    END IF;

    RETURN QUERY
    WITH search_results AS (
        SELECT 
            p.id,
            p.title,
            p.description,
            p.target_amount,
            p.current_amount,
            p.start_date,
            p.end_date,
            p.created_at,
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
                p.title &@ search_query
                OR p.description &@ search_query
                OR u.nickname &@ search_query
            )
    )
    SELECT 
        sr.*,
        COUNT(*) OVER() as total_count
    FROM search_results sr
    ORDER BY
        CASE WHEN sort_order = 'ASC' THEN
            CASE 
                WHEN sort_by = 'created_at' THEN sr.created_at
                WHEN sort_by = 'current_amount' THEN sr.current_amount
                WHEN sort_by = 'like_count' THEN sr.like_count
                WHEN sort_by = 'days_remaining' THEN sr.days_remaining
            END
        ELSE
            CASE 
                WHEN sort_by = 'created_at' THEN sr.created_at
                WHEN sort_by = 'current_amount' THEN sr.current_amount
                WHEN sort_by = 'like_count' THEN sr.like_count
                WHEN sort_by = 'days_remaining' THEN sr.days_remaining
            END
        END;
END;
$$ LANGUAGE plpgsql;

-- プロジェクト一覧取得用の関数（エラー処理付き）
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
    created_at TIMESTAMP WITH TIME ZONE,
    creator_nickname TEXT,
    creator_profile_image TEXT,
    like_count BIGINT,
    supporter_count BIGINT,
    days_remaining INTEGER,
    status TEXT,
    office_status TEXT,
    total_count BIGINT
) AS $$
DECLARE
    valid_sort_columns TEXT[] := ARRAY['created_at', 'current_amount', 'like_count', 'days_remaining'];
    valid_sort_orders TEXT[] := ARRAY['ASC', 'DESC'];
BEGIN
    -- ソート条件の検証
    IF sort_by != ALL(valid_sort_columns) THEN
        RAISE EXCEPTION '無効なソート条件です。有効な値: %', valid_sort_columns;
    END IF;

    IF sort_order != ALL(valid_sort_orders) THEN
        RAISE EXCEPTION '無効なソート順序です。有効な値: %', valid_sort_orders;
    END IF;

    -- ページネーションパラメータの検証
    IF limit_count < 1 THEN
        RAISE EXCEPTION 'limit_countは1以上である必要があります。';
    END IF;

    IF offset_count < 0 THEN
        RAISE EXCEPTION 'offset_countは0以上である必要があります。';
    END IF;

    RETURN QUERY
    WITH project_list AS (
        SELECT 
            p.id,
            p.title,
            p.description,
            p.target_amount,
            p.current_amount,
            p.start_date,
            p.end_date,
            p.created_at,
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
    )
    SELECT 
        pl.*,
        COUNT(*) OVER() as total_count
    FROM project_list pl
    ORDER BY
        CASE WHEN sort_order = 'ASC' THEN
            CASE 
                WHEN sort_by = 'created_at' THEN pl.created_at
                WHEN sort_by = 'current_amount' THEN pl.current_amount
                WHEN sort_by = 'like_count' THEN pl.like_count
                WHEN sort_by = 'days_remaining' THEN pl.days_remaining
            END
        ELSE
            CASE 
                WHEN sort_by = 'created_at' THEN pl.created_at
                WHEN sort_by = 'current_amount' THEN pl.current_amount
                WHEN sort_by = 'like_count' THEN pl.like_count
                WHEN sort_by = 'days_remaining' THEN pl.days_remaining
            END
        END
    LIMIT limit_count
    OFFSET offset_count;
END;
$$ LANGUAGE plpgsql; 