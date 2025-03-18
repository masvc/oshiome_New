import { createMocks } from 'node-mocks-http';
import { NextResponse, NextRequest } from 'next/server';
import { middleware } from '../../middleware';
import { supabase } from '../../lib/supabase';

// NextResponseとNextRequestのモック
jest.mock('next/server', () => {
  const originalModule = jest.requireActual('next/server');
  return {
    ...originalModule,
    NextResponse: {
      next: jest.fn(() => ({
        headers: new Map(),
        cookies: {
          getSetCookie: jest.fn(() => []),
        },
      })),
      redirect: jest.fn((url) => ({ url })),
    },
    NextRequest: jest.fn().mockImplementation((url) => ({
      url,
      nextUrl: {
        pathname: new URL(url).pathname,
      },
      cookies: {
        get: jest.fn(),
      },
    })),
  };
});

describe('認証ミドルウェア', () => {
  let mockSingle: jest.Mock;
  let mockEq: jest.Mock;
  let mockSelect: jest.Mock;
  let mockFrom: jest.Mock;

  beforeEach(() => {
    jest.clearAllMocks();
    
    // デフォルトでは未認証状態にする
    (supabase.auth.getSession as jest.Mock).mockResolvedValue({
      data: { session: null },
    });

    // プロフィール取得のモック
    mockSingle = jest.fn().mockResolvedValue({
      data: { role: 'user' },
      error: null,
    });

    mockEq = jest.fn().mockReturnValue({ single: mockSingle });
    mockSelect = jest.fn().mockReturnValue({ eq: mockEq });
    mockFrom = jest.fn().mockReturnValue({ select: mockSelect });

    (supabase.from as jest.Mock).mockImplementation(mockFrom);
  });

  it('認証が必要ないパスの場合、認証なしでアクセスできること', async () => {
    // 一般ページ（認証不要）へのリクエストをモック
    const req = new NextRequest(new URL('http://localhost:3000/'));
    
    await middleware(req);
    
    // NextResponse.next()が呼ばれていることを確認
    expect(NextResponse.next).toHaveBeenCalled();
    expect(NextResponse.redirect).not.toHaveBeenCalled();
  });

  it('認証が必要なパスで未認証の場合、ログインページにリダイレクトされること', async () => {
    // ダッシュボード（認証必要）へのリクエストをモック
    const req = new NextRequest(new URL('http://localhost:3000/dashboard'));
    
    await middleware(req);
    
    // リダイレクトが呼ばれていることを確認
    expect(NextResponse.redirect).toHaveBeenCalledWith(
      expect.objectContaining({
        pathname: '/login'
      })
    );
  });

  it('認証済みユーザーが認証が必要なパスにアクセスできること', async () => {
    // 認証済みの状態にモック
    (supabase.auth.getSession as jest.Mock).mockResolvedValue({
      data: { 
        session: { 
          user: { id: 'test-user-id' } 
        } 
      },
    });
    
    // ダッシュボードへのリクエストをモック
    const req = new NextRequest(new URL('http://localhost:3000/dashboard'));
    
    await middleware(req);
    
    // NextResponse.next()が呼ばれていることを確認
    expect(NextResponse.next).toHaveBeenCalled();
    expect(NextResponse.redirect).not.toHaveBeenCalled();
  });
}); 