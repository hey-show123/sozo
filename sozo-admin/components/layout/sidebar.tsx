'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { 
  BookOpen, 
  GraduationCap, 
  Layout, 
  LogOut, 
  Package,
  Settings,
  Users 
} from 'lucide-react'
import { createClient } from '@/lib/supabase'
import { useRouter } from 'next/navigation'

const navigation = [
  { name: 'ダッシュボード', href: '/', icon: Layout },
  { name: 'コース管理', href: '/courses', icon: GraduationCap },
  { name: 'モジュール管理', href: '/modules', icon: Package },
  { name: 'レッスン管理', href: '/lessons', icon: BookOpen },
  { name: 'ユーザー管理', href: '/users', icon: Users },
  { name: '設定', href: '/settings', icon: Settings },
]

export default function Sidebar() {
  const pathname = usePathname()
  const router = useRouter()
  const supabase = createClient()

  const handleLogout = async () => {
    await supabase.auth.signOut()
    router.push('/login')
    router.refresh()
  }

  return (
    <div className="flex h-full w-64 flex-col bg-gray-900">
      <div className="flex h-16 items-center px-4">
        <h1 className="text-xl font-semibold text-white">SoZO Admin</h1>
      </div>
      <nav className="flex-1 space-y-1 px-2 pb-4">
        {navigation.map((item) => {
          const isActive = pathname === item.href
          return (
            <Link
              key={item.name}
              href={item.href}
              className={`
                group flex items-center px-2 py-2 text-sm font-medium rounded-md
                ${isActive 
                  ? 'bg-gray-800 text-white' 
                  : 'text-gray-300 hover:bg-gray-700 hover:text-white'
                }
              `}
            >
              <item.icon
                className={`
                  mr-3 h-6 w-6 flex-shrink-0
                  ${isActive ? 'text-white' : 'text-gray-400 group-hover:text-gray-300'}
                `}
              />
              {item.name}
            </Link>
          )
        })}
      </nav>
      <div className="px-2 pb-4">
        <button
          onClick={handleLogout}
          className="group flex w-full items-center px-2 py-2 text-sm font-medium rounded-md text-gray-300 hover:bg-gray-700 hover:text-white"
        >
          <LogOut className="mr-3 h-6 w-6 flex-shrink-0 text-gray-400 group-hover:text-gray-300" />
          ログアウト
        </button>
      </div>
    </div>
  )
} 