import { useEffect, useState } from 'react'
import { supabase } from '../supabase'
import { User } from '@supabase/supabase-js'

export type UserRole = 'user' | 'organizer' | 'admin'

interface Profile {
  username: string
  role: UserRole
  is_active: boolean
  avatar_url: string | null
}

interface AuthState {
  user: User | null
  profile: Profile | null
  loading: boolean
  error: Error | null
}

export function useAuth() {
  const [authState, setAuthState] = useState<AuthState>({
    user: null,
    profile: null,
    loading: true,
    error: null,
  })

  useEffect(() => {
    // 現在のセッションを取得
    supabase.auth.getSession().then(({ data: { session } }) => {
      if (session?.user) {
        fetchProfile(session.user)
      } else {
        setAuthState(prev => ({ ...prev, loading: false }))
      }
    })

    // 認証状態の変更を監視
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        if (session?.user) {
          await fetchProfile(session.user)
        } else {
          setAuthState({
            user: null,
            profile: null,
            loading: false,
            error: null,
          })
        }
      }
    )

    return () => {
      subscription.unsubscribe()
    }
  }, [])

  const fetchProfile = async (user: User) => {
    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('username, role, is_active, avatar_url')
        .eq('id', user.id)
        .single()

      if (error) throw error

      setAuthState({
        user,
        profile: data,
        loading: false,
        error: null,
      })
    } catch (error) {
      setAuthState(prev => ({
        ...prev,
        error: error as Error,
        loading: false,
      }))
    }
  }

  const isOrganizer = () => authState.profile?.role === 'organizer'
  const isAdmin = () => authState.profile?.role === 'admin'
  const isActive = () => authState.profile?.is_active ?? false

  return {
    user: authState.user,
    profile: authState.profile,
    loading: authState.loading,
    error: authState.error,
    isOrganizer,
    isAdmin,
    isActive,
  }
} 