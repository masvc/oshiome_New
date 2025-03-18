import React from 'react'
import { Auth } from '@supabase/auth-ui-react'
import { ThemeSupa } from '@supabase/auth-ui-shared'
import { supabase } from '../lib/supabase'

export default function AuthComponent() {
  return (
    <div className="w-full max-w-md mx-auto p-4">
      <Auth
        supabaseClient={supabase}
        appearance={{ theme: ThemeSupa }}
        providers={['twitter']}
        redirectTo={`${window.location.origin}/auth/callback`}
        localization={{
          variables: {
            sign_in: {
              email_label: 'メールアドレス',
              password_label: 'パスワード',
              button_label: 'ログイン',
              loading_button_label: 'ログイン中...',
              social_provider_text: '{{provider}}でログイン',
            },
            sign_up: {
              email_label: 'メールアドレス',
              password_label: 'パスワード',
              button_label: '新規登録',
              loading_button_label: '登録中...',
              social_provider_text: '{{provider}}で登録',
            },
          },
        }}
      />
    </div>
  )
} 