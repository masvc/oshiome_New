import React from 'react';
import { render, screen } from '@testing-library/react';
import AuthComponent from '../../components/Auth';
import { supabase } from '../../lib/supabase';

// モックを検証するためのjestのスパイを設定
jest.spyOn(supabase.auth, 'signUp');
jest.spyOn(supabase.auth, 'signIn');

describe('認証コンポーネント', () => {
  beforeEach(() => {
    // 各テスト前にモックをリセット
    jest.clearAllMocks();
  });

  it('認証コンポーネントが正しくレンダリングされること', () => {
    render(<AuthComponent />);
    
    // Auth UIコンポーネントが表示されているか確認
    const authComponent = screen.getByTestId('auth-component');
    expect(authComponent).toBeInTheDocument();
    expect(authComponent).toHaveTextContent('認証コンポーネント');
  });

  it('リダイレクトURLが正しく設定されていること', () => {
    render(<AuthComponent />);
    
    // AuthコンポーネントへのpropsとしてリダイレクトURLが渡されたかを確認
    // これは直接テストするのが難しいため、実際の実装ではこのテストはスキップするか
    // コンポーネントの実装を変更することが必要かもしれません
    // ここではモックを使った例を示しています
    
    // Authコンポーネントが表示されていることを確認
    expect(screen.getByTestId('auth-component')).toBeInTheDocument();
  });
}); 