-- ユーザーロールの列挙型を作成
CREATE TYPE user_role AS ENUM ('user', 'organizer', 'admin');

-- プロファイルテーブルの作成
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
  username TEXT UNIQUE,
  role user_role DEFAULT 'user',
  is_active BOOLEAN DEFAULT true,
  avatar_url TEXT,
  
  PRIMARY KEY (id),
  CONSTRAINT username_length CHECK (char_length(username) >= 3)
);

-- プロファイルを自動作成するトリガー
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, username)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'username', NEW.email)
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- auth.usersテーブルへのトリガー設定
CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user(); 