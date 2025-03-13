-- プロジェクトの集計情報をキャッシュするテーブル
CREATE TABLE project_stats_cache (
    project_id UUID PRIMARY KEY REFERENCES projects(id),
    like_count BIGINT NOT NULL DEFAULT 0,
    supporter_count BIGINT NOT NULL DEFAULT 0,
    total_amount BIGINT NOT NULL DEFAULT 0,
    days_remaining INTEGER,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- キャッシュを更新する関数
CREATE OR REPLACE FUNCTION update_project_stats_cache()
RETURNS void AS $$
BEGIN
    -- 既存のキャッシュを更新
    UPDATE project_stats_cache psc
    SET 
        like_count = (SELECT COUNT(*) FROM project_likes WHERE project_id = psc.project_id),
        supporter_count = (SELECT COUNT(*) FROM project_supports WHERE project_id = psc.project_id),
        total_amount = (SELECT COALESCE(SUM(amount), 0) FROM project_supports WHERE project_id = psc.project_id),
        days_remaining = EXTRACT(DAY FROM (p.end_date - CURRENT_TIMESTAMP)),
        updated_at = CURRENT_TIMESTAMP
    FROM projects p
    WHERE p.id = psc.project_id;

    -- 新規プロジェクトのキャッシュを追加
    INSERT INTO project_stats_cache (project_id, like_count, supporter_count, total_amount, days_remaining)
    SELECT 
        p.id,
        (SELECT COUNT(*) FROM project_likes WHERE project_id = p.id),
        (SELECT COUNT(*) FROM project_supports WHERE project_id = p.id),
        (SELECT COALESCE(SUM(amount), 0) FROM project_supports WHERE project_id = p.id),
        EXTRACT(DAY FROM (p.end_date - CURRENT_TIMESTAMP))
    FROM projects p
    WHERE NOT EXISTS (SELECT 1 FROM project_stats_cache WHERE project_id = p.id);
END;
$$ LANGUAGE plpgsql;

-- プロジェクトのいいねが変更された時のトリガー
CREATE OR REPLACE FUNCTION update_project_stats_on_like_change()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE project_stats_cache
    SET 
        like_count = (SELECT COUNT(*) FROM project_likes WHERE project_id = NEW.project_id),
        updated_at = CURRENT_TIMESTAMP
    WHERE project_id = NEW.project_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_stats_on_like
    AFTER INSERT OR DELETE ON project_likes
    FOR EACH ROW
    EXECUTE FUNCTION update_project_stats_on_like_change();

-- プロジェクトの支援が変更された時のトリガー
CREATE OR REPLACE FUNCTION update_project_stats_on_support_change()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE project_stats_cache
    SET 
        supporter_count = (SELECT COUNT(*) FROM project_supports WHERE project_id = NEW.project_id),
        total_amount = (SELECT COALESCE(SUM(amount), 0) FROM project_supports WHERE project_id = NEW.project_id),
        updated_at = CURRENT_TIMESTAMP
    WHERE project_id = NEW.project_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_stats_on_support
    AFTER INSERT OR DELETE ON project_supports
    FOR EACH ROW
    EXECUTE FUNCTION update_project_stats_on_support_change(); 