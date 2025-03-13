-- テストユーザーの作成
INSERT INTO users (nickname, email, password_hash, bio) VALUES
('テストユーザー1', 'test1@example.com', 'hashed_password_1', 'テストユーザー1の自己紹介です。'),
('テストユーザー2', 'test2@example.com', 'hashed_password_2', 'テストユーザー2の自己紹介です。'),
('テストユーザー3', 'test3@example.com', 'hashed_password_3', 'テストユーザー3の自己紹介です。');

-- テストユーザーのSNSリンク
INSERT INTO user_social_links (user_id, platform, url) VALUES
((SELECT id FROM users WHERE email = 'test1@example.com'), 'twitter', 'https://twitter.com/test1'),
((SELECT id FROM users WHERE email = 'test2@example.com'), 'twitter', 'https://twitter.com/test2'),
((SELECT id FROM users WHERE email = 'test3@example.com'), 'twitter', 'https://twitter.com/test3');

-- テストプロジェクトの作成
INSERT INTO projects (title, description, target_amount, current_amount, start_date, end_date, creator_id, idol_name, office_status, status) VALUES
('アイドルAの誕生日広告', 'アイドルAの誕生日を祝うための広告プロジェクトです。', 100000, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '30 days', 
 (SELECT id FROM users WHERE email = 'test1@example.com'), 'アイドルA', 'approved', 'active'),
('アイドルBの誕生日広告', 'アイドルBの誕生日を祝うための広告プロジェクトです。', 200000, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '60 days',
 (SELECT id FROM users WHERE email = 'test2@example.com'), 'アイドルB', 'approved', 'active'),
('アイドルCの誕生日広告', 'アイドルCの誕生日を祝うための広告プロジェクトです。', 300000, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '90 days',
 (SELECT id FROM users WHERE email = 'test3@example.com'), 'アイドルC', 'pending', 'draft');

-- テストいいね
INSERT INTO project_likes (user_id, project_id) VALUES
((SELECT id FROM users WHERE email = 'test1@example.com'), (SELECT id FROM projects WHERE title = 'アイドルBの誕生日広告')),
((SELECT id FROM users WHERE email = 'test2@example.com'), (SELECT id FROM projects WHERE title = 'アイドルAの誕生日広告')),
((SELECT id FROM users WHERE email = 'test3@example.com'), (SELECT id FROM projects WHERE title = 'アイドルAの誕生日広告'));

-- テスト支援
INSERT INTO project_supports (user_id, project_id, amount) VALUES
((SELECT id FROM users WHERE email = 'test1@example.com'), (SELECT id FROM projects WHERE title = 'アイドルBの誕生日広告'), 5000),
((SELECT id FROM users WHERE email = 'test2@example.com'), (SELECT id FROM projects WHERE title = 'アイドルAの誕生日広告'), 10000),
((SELECT id FROM users WHERE email = 'test3@example.com'), (SELECT id FROM projects WHERE title = 'アイドルAの誕生日広告'), 15000);

-- キャッシュの更新
SELECT update_project_stats_cache(); 