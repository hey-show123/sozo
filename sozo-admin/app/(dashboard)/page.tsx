import { createServerSupabaseClient } from '@/lib/supabase-server'
import { redirect } from 'next/navigation'
import { BookOpen, GraduationCap, Package, Users, ArrowUp, Plus } from 'lucide-react'

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
    { 
      name: 'コース数', 
      value: coursesCount || 0, 
      icon: GraduationCap, 
      change: '+12%',
      trend: 'up'
    },
    { 
      name: 'モジュール数', 
      value: modulesCount || 0, 
      icon: Package, 
      change: '+8%',
      trend: 'up'
    },
    { 
      name: 'レッスン数', 
      value: lessonsCount || 0, 
      icon: BookOpen, 
      change: '+15%',
      trend: 'up'
    },
    { 
      name: 'ユーザー数', 
      value: usersCount || 0, 
      icon: Users, 
      change: '+23%',
      trend: 'up'
    },
  ]

  return (
    <>
      <div className="mb-10">
        <h1 className="text-3xl font-bold text-text-primary dark:text-text-primary tracking-tight">
          ダッシュボード
        </h1>
        <p className="mt-2 text-text-secondary dark:text-text-secondary">
          SoZO学習コンテンツの管理
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-10">
        {stats.map((stat) => {
          const Icon = stat.icon
          return (
            <div 
              key={stat.name} 
              className="bg-card dark:bg-card border border-border dark:border-border rounded-2xl p-6 
                         hover:shadow-lg transition-all duration-300 card-hover"
            >
              <div className="flex justify-between items-start mb-4">
                <div className="bg-background dark:bg-background rounded-xl p-3">
                  <Icon className="h-6 w-6 text-primary dark:text-primary" />
                </div>
                <div className={`flex items-center gap-1 text-xs font-medium ${
                  stat.trend === 'up' ? 'text-success' : 'text-error'
                }`}>
                  <ArrowUp className="h-3 w-3" />
                  {stat.change}
                </div>
              </div>
              <div>
                <p className="text-sm font-medium text-text-tertiary dark:text-text-tertiary mb-1">
                  {stat.name}
                </p>
                <p className="text-3xl font-bold text-text-primary dark:text-text-primary tracking-tight">
                  {stat.value.toLocaleString()}
                </p>
              </div>
            </div>
          )
        })}
      </div>

      <div className="bg-card dark:bg-card border border-border dark:border-border rounded-2xl p-8 shadow-sm">
        <div className="flex justify-between items-center mb-8">
          <div>
            <h2 className="text-xl font-bold text-text-primary dark:text-text-primary tracking-tight">
              クイックアクション
            </h2>
            <p className="text-sm text-text-secondary dark:text-text-secondary mt-1">
              新しいコンテンツを作成して学習体験を充実させましょう
            </p>
          </div>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <a
            href="/courses/new"
            className="group relative overflow-hidden border-2 border-dashed border-border dark:border-border 
                       rounded-xl p-8 hover:border-primary dark:hover:border-primary 
                       hover:bg-background dark:hover:bg-background transition-all duration-300
                       flex flex-col items-center text-center"
          >
            <div className="bg-primary/10 dark:bg-primary/20 rounded-2xl p-4 mb-4 
                          group-hover:scale-110 transition-transform duration-300">
              <GraduationCap className="h-8 w-8 text-primary dark:text-primary" />
            </div>
            <p className="text-base font-semibold text-text-primary dark:text-text-primary mb-1">
              新しいコースを作成
            </p>
            <p className="text-sm text-text-secondary dark:text-text-secondary">
              学習コースを追加
            </p>
            <Plus className="absolute bottom-4 right-4 h-5 w-5 text-text-tertiary 
                           group-hover:text-primary transition-colors duration-300" />
          </a>
          <a
            href="/lessons/new"
            className="group relative overflow-hidden border-2 border-dashed border-border dark:border-border 
                       rounded-xl p-8 hover:border-primary dark:hover:border-primary 
                       hover:bg-background dark:hover:bg-background transition-all duration-300
                       flex flex-col items-center text-center"
          >
            <div className="bg-accent/10 dark:bg-accent/20 rounded-2xl p-4 mb-4 
                          group-hover:scale-110 transition-transform duration-300">
              <BookOpen className="h-8 w-8 text-accent dark:text-accent" />
            </div>
            <p className="text-base font-semibold text-text-primary dark:text-text-primary mb-1">
              新しいレッスンを作成
            </p>
            <p className="text-sm text-text-secondary dark:text-text-secondary">
              レッスンコンテンツを追加
            </p>
            <Plus className="absolute bottom-4 right-4 h-5 w-5 text-text-tertiary 
                           group-hover:text-accent transition-colors duration-300" />
          </a>
          <a
            href="/users"
            className="group relative overflow-hidden border-2 border-dashed border-border dark:border-border 
                       rounded-xl p-8 hover:border-primary dark:hover:border-primary 
                       hover:bg-background dark:hover:bg-background transition-all duration-300
                       flex flex-col items-center text-center"
          >
            <div className="bg-secondary/10 dark:bg-secondary/20 rounded-2xl p-4 mb-4 
                          group-hover:scale-110 transition-transform duration-300">
              <Users className="h-8 w-8 text-secondary dark:text-secondary" />
            </div>
            <p className="text-base font-semibold text-text-primary dark:text-text-primary mb-1">
              ユーザー管理
            </p>
            <p className="text-sm text-text-secondary dark:text-text-secondary">
              学習者を管理
            </p>
            <Plus className="absolute bottom-4 right-4 h-5 w-5 text-text-tertiary 
                           group-hover:text-secondary transition-colors duration-300" />
          </a>
        </div>
      </div>
    </>
  )
} 