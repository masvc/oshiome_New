import { createMiddlewareClient } from '@supabase/auth-helpers-nextjs'
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export async function middleware(request: NextRequest) {
  const res = NextResponse.next()
  const supabase = createMiddlewareClient({ req: request, res })

  // セッションの更新
  const {
    data: { session },
  } = await supabase.auth.getSession()

  // 認証が必要なルートのパターン
  const authRequiredPattern = /^\/(?:dashboard|projects\/create|admin)/

  // 管理者専用ルートのパターン
  const adminOnlyPattern = /^\/admin/

  const path = request.nextUrl.pathname

  if (authRequiredPattern.test(path)) {
    if (!session) {
      // 未認証の場合はログインページにリダイレクト
      return NextResponse.redirect(new URL('/login', request.url))
    }

    if (adminOnlyPattern.test(path)) {
      // 管理者権限の確認
      const { data: profile } = await supabase
        .from('profiles')
        .select('role')
        .eq('id', session.user.id)
        .single()

      if (profile?.role !== 'admin') {
        // 管理者でない場合はホームページにリダイレクト
        return NextResponse.redirect(new URL('/', request.url))
      }
    }
  }

  return res
}

export const config = {
  matcher: [
    /*
     * 以下のパスに対してミドルウェアを適用:
     * - /dashboard で始まるすべてのルート
     * - /projects/create
     * - /admin で始まるすべてのルート
     */
    '/dashboard/:path*',
    '/projects/create',
    '/admin/:path*',
  ],
} 