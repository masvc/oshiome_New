-- 支援金額を更新する関数
CREATE OR REPLACE FUNCTION update_project_current_amount()
RETURNS TRIGGER AS $$
BEGIN
    -- トランザクション内で実行
    UPDATE projects
    SET 
        current_amount = (
            SELECT COALESCE(SUM(amount), 0)
            FROM project_supports
            WHERE project_id = NEW.project_id
        ),
        updated_at = CURRENT_TIMESTAMP
    WHERE id = NEW.project_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 支援が追加された時のトリガー
CREATE TRIGGER update_project_amount_on_support
    AFTER INSERT ON project_supports
    FOR EACH ROW
    EXECUTE FUNCTION update_project_current_amount();

-- 支援が削除された時のトリガー
CREATE TRIGGER update_project_amount_on_support_delete
    AFTER DELETE ON project_supports
    FOR EACH ROW
    EXECUTE FUNCTION update_project_current_amount(); 