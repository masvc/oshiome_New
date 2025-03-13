-- サンプルユーザーの挿入
INSERT INTO users (nickname, email, password_hash, bio) VALUES
('サンプルユーザー1', 'sample1@example.com', 'hashed_password_1', 'サンプルユーザー1の自己紹介です。'),
('サンプルユーザー2', 'sample2@example.com', 'hashed_password_2', 'サンプルユーザー2の自己紹介です。');

-- サンプルSNSリンクの挿入
INSERT INTO user_social_links (user_id, platform, url) VALUES
((SELECT id FROM users WHERE email = 'sample1@example.com'), 'twitter', 'https://twitter.com/sample1'),
((SELECT id FROM users WHERE email = 'sample2@example.com'), 'twitter', 'https://twitter.com/sample2');

-- サンプルプロジェクトの挿入
INSERT INTO projects (title, description, target_amount, current_amount, start_date, end_date, creator_id, idol_name, office_status, status) VALUES
('サンプルプロジェクト1', 'これはサンプルプロジェクト1の説明です。', 100000, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '30 days', 
 (SELECT id FROM users WHERE email = 'sample1@example.com'), 'サンプルアイドル1', 'approved', 'active'),
('サンプルプロジェクト2', 'これはサンプルプロジェクト2の説明です。', 200000, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '60 days',
 (SELECT id FROM users WHERE email = 'sample2@example.com'), 'サンプルアイドル2', 'approved', 'active');

-- サンプルいいねの挿入
INSERT INTO project_likes (user_id, project_id) VALUES
((SELECT id FROM users WHERE email = 'sample1@example.com'), (SELECT id FROM projects WHERE title = 'サンプルプロジェクト2')),
((SELECT id FROM users WHERE email = 'sample2@example.com'), (SELECT id FROM projects WHERE title = 'サンプルプロジェクト1'));

-- サンプル支援の挿入
INSERT INTO project_supports (user_id, project_id, amount) VALUES
((SELECT id FROM users WHERE email = 'sample1@example.com'), (SELECT id FROM projects WHERE title = 'サンプルプロジェクト2'), 5000),
((SELECT id FROM users WHERE email = 'sample2@example.com'), (SELECT id FROM projects WHERE title = 'サンプルプロジェクト1'), 10000); 