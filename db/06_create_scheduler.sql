-- 期限切れチェックのスケジューラー設定
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- 毎日午前0時に期限切れチェックを実行
SELECT cron.schedule('0 0 * * *', $$
    SELECT check_project_end_date();
$$); 