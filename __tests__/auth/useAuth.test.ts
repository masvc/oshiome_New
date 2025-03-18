import { renderHook } from '@testing-library/react';
import { waitFor } from '@testing-library/dom';
import { useAuth } from '../../lib/hooks/useAuth';
import { supabase } from '../../lib/supabase';

// モックデータ
const mockUser = {
  id: 'test-user-id',
  email: 'test@example.com',
};

const mockProfile = {
  username: 'テストユーザー',
  role: 'user',
  is_active: true,
  avatar_url: null,
};

describe('useAuthフック', () => {
  beforeEach(() => {
    jest.clearAllMocks();

    // getSessionのモック実装
    (supabase.auth.getSession as jest.Mock).mockResolvedValue({
      data: { session: { user: mockUser } },
    });

    // onAuthStateChangeのモック実装
    (supabase.auth.onAuthStateChange as jest.Mock).mockReturnValue({
      data: {
        subscription: {
          unsubscribe: jest.fn(),
        },
      },
    });

    // fromメソッドチェーンのモック実装
    const mockSingle = jest.fn().mockResolvedValue({
      data: mockProfile,
      error: null,
    });
    
    const mockEq = jest.fn().mockReturnValue({ single: mockSingle });
    const mockSelect = jest.fn().mockReturnValue({ eq: mockEq });
    const mockFrom = jest.fn().mockReturnValue({ select: mockSelect });
    
    (supabase.from as jest.Mock).mockImplementation(mockFrom);
  });

  it('初期状態ではローディング中であること', () => {
    const { result } = renderHook(() => useAuth());
    
    expect(result.current.loading).toBe(true);
    expect(result.current.user).toBeNull();
    expect(result.current.profile).toBeNull();
    expect(result.current.error).toBeNull();
  });

  it('ユーザーのプロフィールが正しく取得できること', async () => {
    const { result } = renderHook(() => useAuth());
    
    // プロフィール取得の非同期処理完了を待つ
    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });
    
    // 取得したデータが正しいことを確認
    expect(result.current.user).toEqual(mockUser);
    expect(result.current.profile).toEqual(mockProfile);
    expect(result.current.error).toBeNull();
    
    // 役割の確認メソッドが正しく機能することを確認
    expect(result.current.isAdmin()).toBe(false);
    expect(result.current.isOrganizer()).toBe(false);
    expect(result.current.isActive()).toBe(true);
  });

  it('管理者ユーザーの場合にisAdmin()がtrueを返すこと', async () => {
    // 管理者プロフィールのモック
    const adminProfile = { ...mockProfile, role: 'admin' };
    
    // fromメソッドチェーンのモックを上書き
    const mockSingle = jest.fn().mockResolvedValue({
      data: adminProfile,
      error: null,
    });
    
    const mockEq = jest.fn().mockReturnValue({ single: mockSingle });
    const mockSelect = jest.fn().mockReturnValue({ eq: mockEq });
    const mockFrom = jest.fn().mockReturnValue({ select: mockSelect });
    
    (supabase.from as jest.Mock).mockImplementation(mockFrom);
    
    const { result } = renderHook(() => useAuth());
    
    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });
    
    expect(result.current.isAdmin()).toBe(true);
    expect(result.current.isOrganizer()).toBe(false);
  });

  it('企画者ユーザーの場合にisOrganizer()がtrueを返すこと', async () => {
    // 企画者プロフィールのモック
    const organizerProfile = { ...mockProfile, role: 'organizer' };
    
    // fromメソッドチェーンのモックを上書き
    const mockSingle = jest.fn().mockResolvedValue({
      data: organizerProfile,
      error: null,
    });
    
    const mockEq = jest.fn().mockReturnValue({ single: mockSingle });
    const mockSelect = jest.fn().mockReturnValue({ eq: mockEq });
    const mockFrom = jest.fn().mockReturnValue({ select: mockSelect });
    
    (supabase.from as jest.Mock).mockImplementation(mockFrom);
    
    const { result } = renderHook(() => useAuth());
    
    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });
    
    expect(result.current.isAdmin()).toBe(false);
    expect(result.current.isOrganizer()).toBe(true);
  });
}); 