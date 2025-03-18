import { GET } from '../../app/auth/callback/route';
import { supabase } from '../../lib/supabase';
import { NextResponse } from 'next/server';

// NextResponseのモック
jest.mock('next/server', () => {
  const originalModule = jest.requireActual('next/server');
  return {
    ...originalModule,
    NextResponse: {
      redirect: jest.fn((url) => ({ url })),
    },
  };
});

describe('認証コールバックハンドラー', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('コードがない場合は直接リダイレクトすること', async () => {
    const request = new Request('http://localhost:3000/auth/callback');
    
    await GET(request);
    
    // セッション交換が呼ばれていないことを確認
    expect(supabase.auth.exchangeCodeForSession).not.toHaveBeenCalled();
    
    // リダイレクトが呼ばれていることを確認
    expect(NextResponse.redirect).toHaveBeenCalledWith(
      expect.objectContaining({
        pathname: '/'
      })
    );
  });

  it('コードがある場合はセッション交換してからリダイレクトすること', async () => {
    const request = new Request('http://localhost:3000/auth/callback?code=test-code');
    
    // セッション交換のモック
    (supabase.auth.exchangeCodeForSession as jest.Mock).mockResolvedValue({
      data: { session: { user: { id: 'test-user-id' } } },
      error: null,
    });
    
    await GET(request);
    
    // セッション交換が呼ばれていることを確認
    expect(supabase.auth.exchangeCodeForSession).toHaveBeenCalledWith('test-code');
    
    // リダイレクトが呼ばれていることを確認
    expect(NextResponse.redirect).toHaveBeenCalledWith(
      expect.objectContaining({
        pathname: '/'
      })
    );
  });
}); 