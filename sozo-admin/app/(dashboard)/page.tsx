import { createServerSupabaseClient } from '@/lib/supabase-server'
import { redirect } from 'next/navigation'
import { BookOpen, GraduationCap, Package, Users } from 'lucide-react'

export default async function DashboardPage() {
  const supabase = await createServerSupabaseClient()
  
  const { data: { user } } = await supabase.auth.getUser()
  
  if (!user) {
    redirect('/login')
  }

  // 統計情報を取得
  const [
    { count: coursesCount },
    { count: modulesCount },
    { count: lessonsCount },
    { count: usersCount }
  ] = await Promise.all([
    supabase.from('courses').select('*', { count: 'exact', head: true }),
    supabase.from('modules').select('*', { count: 'exact', head: true }),
    supabase.from('lessons').select('*', { count: 'exact', head: true }),
    supabase.from('profiles').select('*', { count: 'exact', head: true })
  ])

  const stats = [
    { name: 'コース数', value: coursesCount || 0, icon: GraduationCap, color: 'bg-blue-500' },
    { name: 'モジュール数', value: modulesCount || 0, icon: Package, color: 'bg-green-500' },
    { name: 'レッスン数', value: lessonsCount || 0, icon: BookOpen, color: 'bg-purple-500' },
    { name: 'ユーザー数', value: usersCount || 0, icon: Users, color: 'bg-orange-500' },
  ]

  return (
    <div className="p-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">ダッシュボード</h1>
        <p className="mt-2 text-gray-600">SoZO学習コンテンツの管理</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        {stats.map((stat) => {
          const Icon = stat.icon
          return (
            <div key={stat.name} className="bg-white rounded-lg shadow p-6">
              <div className="flex items-center">
                <div className={`${stat.color} rounded-lg p-3 text-white`}>
                  <Icon className="h-6 w-6" />
                </div>
                <div className="ml-4">
                  <p className="text-sm font-medium text-gray-600">{stat.name}</p>
                  <p className="text-2xl font-semibold text-gray-900">{stat.value}</p>
                </div>
              </div>
            </div>
          )
        })}
      </div>

      <div className="bg-white shadow rounded-lg p-6">
        <h2 className="text-xl font-semibold mb-4">クイックアクション</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <a
            href="/courses/new"
            className="p-4 border-2 border-dashed border-gray-300 rounded-lg hover:border-gray-400 hover:bg-gray-50 text-center transition-colors"
          >
            <GraduationCap className="h-8 w-8 mx-auto mb-2 text-gray-400" />
            <p className="text-sm font-medium text-gray-900">新しいコースを作成</p>
          </a>
          <a
            href="/lessons/new"
            className="p-4 border-2 border-dashed border-gray-300 rounded-lg hover:border-gray-400 hover:bg-gray-50 text-center transition-colors"
          >
            <BookOpen className="h-8 w-8 mx-auto mb-2 text-gray-400" />
            <p className="text-sm font-medium text-gray-900">新しいレッスンを作成</p>
          </a>
          <a
            href="/users"
            className="p-4 border-2 border-dashed border-gray-300 rounded-lg hover:border-gray-400 hover:bg-gray-50 text-center transition-colors"
          >
            <Users className="h-8 w-8 mx-auto mb-2 text-gray-400" />
            <p className="text-sm font-medium text-gray-900">ユーザー管理</p>
          </a>
        </div>
      </div>
    </div>
  )
} 