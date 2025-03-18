// Learn more: https://github.com/testing-library/jest-dom
import '@testing-library/jest-dom';

// テスト用に環境変数をモック
process.env.NEXT_PUBLIC_SUPABASE_URL = 'https://example.supabase.co';
process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY = 'dummy-anon-key';

// Requestオブジェクトのモック
global.Request = class Request {
  constructor(url, options = {}) {
    Object.defineProperty(this, 'url', {
      value: url,
      writable: true
    });
    this.options = options;
  }
};

// NextRequestのモック
global.NextRequest = class NextRequest extends Request {
  constructor(url, options = {}) {
    super(url, options);
    this.cookies = {
      get: jest.fn(),
      getAll: jest.fn(),
      set: jest.fn(),
      delete: jest.fn(),
    };
  }
};

// Responseオブジェクトのモック
global.Response = class Response {
  constructor(body, options = {}) {
    this.body = body;
    this.options = options;
  }
};

// Supabaseクライアントのモック
jest.mock('@supabase/supabase-js', () => {
  const auth = {
    signUp: jest.fn(),
    signIn: jest.fn(),
    signOut: jest.fn(),
    onAuthStateChange: jest.fn(() => {
      return { data: { subscription: { unsubscribe: jest.fn() } } };
    }),
    getSession: jest.fn(),
    exchangeCodeForSession: jest.fn(),
  };

  return {
    createClient: jest.fn(() => ({
      auth,
      from: jest.fn(() => ({
        select: jest.fn(() => ({
          eq: jest.fn(() => ({
            single: jest.fn(),
          })),
        })),
      })),
    })),
    createRouteHandlerClient: jest.fn(() => ({
      auth,
    })),
    createMiddlewareClient: jest.fn(() => ({
      auth,
    })),
  };
});

// Auth UIのモック
jest.mock('@supabase/auth-ui-react', () => ({
  Auth: () => <div data-testid="auth-component">認証コンポーネント</div>,
}));

// window.locationのモック
Object.defineProperty(window, 'location', {
  writable: true,
  value: { 
    origin: 'http://localhost:3000',
    href: 'http://localhost:3000' 
  },
});

const { TextEncoder, TextDecoder } = require('util');
global.TextEncoder = TextEncoder;
global.TextDecoder = TextDecoder; 