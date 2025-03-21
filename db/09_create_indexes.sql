-- PGroongaのインストール
CREATE EXTENSION IF NOT EXISTS pgroonga; 

-- 検索用のインデックス
CREATE INDEX idx_projects_title ON projects USING pgroonga (title);
CREATE INDEX idx_projects_description ON projects USING pgroonga (description);
CREATE INDEX idx_users_nickname ON users USING pgroonga (nickname);

-- ソート用のインデックス
CREATE INDEX idx_projects_created_at ON projects(created_at);
CREATE INDEX idx_project_stats_total_amount ON project_stats_cache(total_amount);
CREATE INDEX idx_project_stats_like_count ON project_stats_cache(like_count);
CREATE INDEX idx_project_stats_days_remaining ON project_stats_cache(days_remaining);

