'use client'

import { useEffect, useState } from 'react'
import { createClient } from '@/lib/supabase'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { 
  Plus, 
  Edit, 
  Trash2, 
  BookOpen, 
  Volume2, 
  MessageCircle, 
  Headphones,
  Brain,
  Users,
  Clock
} from 'lucide-react'

interface Lesson {
  id: string
  title: string
  description?: string
  lesson_type?: string
  type?: string
  difficulty?: string
  estimated_minutes?: number
  is_active: boolean
  modules?: { id: string; title: string }
  curriculums?: { id: string; title: string }
  key_phrases?: any[]
  vocabulary_questions?: any[]
  listening_exercises?: any[]
  dialogues?: any[]
  application_exercises?: any[]
  created_at?: string
  updated_at?: string
}

export default function LessonsPage() {
  const [lessons, setLessons] = useState<Lesson[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const router = useRouter()
  const supabase = createClient()

  useEffect(() => {
    loadLessons()
  }, [])

  const loadLessons = async () => {
    try {
      const { data: { user } } = await supabase.auth.getUser()
      
      if (!user) {
        router.push('/login')
        return
      }

      const { data, error } = await supabase
        .from('lessons')
        .select(`
          *,
          curriculums(id, title),
          modules(id, title)
        `)
        .order('created_at', { ascending: false })

      if (error) {
        throw error
      }

      setLessons(data || [])
    } catch (err) {
      console.error('Error fetching lessons:', err)
      setError(err instanceof Error ? err.message : 'レッスンの取得に失敗しました')
    } finally {
      setLoading(false)
    }
  }

  const handleDelete = async (lessonId: string, lessonTitle: string) => {
    if (!confirm(`「${lessonTitle}」を削除しますか？この操作は取り消せません。`)) {
      return
    }

    try {
      const { error } = await supabase
        .from('lessons')
        .delete()
        .eq('id', lessonId)

      if (error) {
        throw error
      }

      // 削除成功後、リストを更新
      setLessons(lessons.filter(lesson => lesson.id !== lessonId))
      alert('レッスンを削除しました')
    } catch (err) {
      console.error('Error deleting lesson:', err)
      alert('レッスンの削除に失敗しました')
    }
  }

  const getLessonTypeIcon = (type: string) => {
    switch (type) {
      case 'conversation':
        return <MessageCircle className="h-4 w-4" />
      case 'pronunciation':
        return <Volume2 className="h-4 w-4" />
      case 'vocabulary':
        return <BookOpen className="h-4 w-4" />
      case 'grammar':
        return <Brain className="h-4 w-4" />
      case 'review':
        return <Users className="h-4 w-4" />
      default:
        return <BookOpen className="h-4 w-4" />
    }
  }

  const getLessonTypeColor = (type: string) => {
    switch (type) {
      case 'conversation':
        return 'bg-blue-100 text-blue-800'
      case 'pronunciation':
        return 'bg-purple-100 text-purple-800'
      case 'vocabulary':
        return 'bg-green-100 text-green-800'
      case 'grammar':
        return 'bg-yellow-100 text-yellow-800'
      case 'review':
        return 'bg-indigo-100 text-indigo-800'
      default:
        return 'bg-gray-100 text-gray-800'
    }
  }

  const getDifficultyColor = (difficulty: string) => {
    switch (difficulty) {
      case 'beginner':
        return 'bg-green-50 text-green-700 border-green-200'
      case 'elementary':
        return 'bg-blue-50 text-blue-700 border-blue-200'
      case 'intermediate':
        return 'bg-yellow-50 text-yellow-700 border-yellow-200'
      case 'advanced':
        return 'bg-red-50 text-red-700 border-red-200'
      default:
        return 'bg-gray-50 text-gray-700 border-gray-200'
    }
  }

  const getDifficultyLabel = (difficulty: string) => {
    switch (difficulty) {
      case 'beginner':
        return '初級'
      case 'elementary':
        return '初中級'
      case 'intermediate':
        return '中級'
      case 'advanced':
        return '上級'
      default:
        return difficulty
    }
  }

  const countExercises = (lesson: Lesson) => {
    let count = 0
    if (lesson.vocabulary_questions?.length) count++
    if (lesson.key_phrases?.length) count++
    if (lesson.listening_exercises?.length) count++
    if (lesson.dialogues?.length) count++
    if (lesson.application_exercises?.length) count++
    return count
  }

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="text-gray-500">読み込み中...</div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="p-8">
        <div className="rounded-md bg-red-50 p-4">
          <div className="flex">
            <div className="ml-3">
              <h3 className="text-sm font-medium text-red-800">エラー</h3>
              <div className="mt-2 text-sm text-red-700">{error}</div>
            </div>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="p-8">
      <div className="mb-8 flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">レッスン管理</h1>
          <p className="mt-2 text-gray-600">レッスンの作成・編集・削除</p>
        </div>
        <Link
          href="/lessons/new"
          className="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
        >
          <Plus className="h-4 w-4 mr-2" />
          新規レッスン
        </Link>
      </div>

      {/* レッスン統計 */}
      <div className="mb-6 grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
        <div className="bg-white overflow-hidden shadow rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <BookOpen className="h-6 w-6 text-gray-400" />
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">総レッスン数</dt>
                  <dd className="text-lg font-medium text-gray-900">{lessons.length}</dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white overflow-hidden shadow rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <Users className="h-6 w-6 text-gray-400" />
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">アクティブ</dt>
                  <dd className="text-lg font-medium text-gray-900">
                    {lessons.filter(l => l.is_active).length}
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white overflow-hidden shadow rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <MessageCircle className="h-6 w-6 text-gray-400" />
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">会話レッスン</dt>
                  <dd className="text-lg font-medium text-gray-900">
                    {lessons.filter(l => (l.type || l.lesson_type) === 'conversation').length}
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white overflow-hidden shadow rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <Clock className="h-6 w-6 text-gray-400" />
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">総学習時間</dt>
                  <dd className="text-lg font-medium text-gray-900">
                    {lessons.reduce((sum, l) => sum + (l.estimated_minutes || 30), 0)}分
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="bg-white shadow rounded-lg overflow-hidden">
        {lessons.length === 0 ? (
          <div className="text-center py-12">
            <BookOpen className="mx-auto h-12 w-12 text-gray-400" />
            <h3 className="mt-2 text-sm font-medium text-gray-900">レッスンがありません</h3>
            <p className="mt-1 text-sm text-gray-500">新しいレッスンを作成してください。</p>
            <div className="mt-6">
              <Link
                href="/lessons/new"
                className="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
              >
                <Plus className="h-4 w-4 mr-2" />
                最初のレッスンを作成
              </Link>
            </div>
          </div>
        ) : (
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  レッスン
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  タイプ
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  難易度
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  練習内容
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  時間
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  ステータス
                </th>
                <th className="relative px-6 py-3">
                  <span className="sr-only">操作</span>
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {lessons.map((lesson) => {
                const lessonType = lesson.type || lesson.lesson_type || 'conversation'
                const exerciseCount = countExercises(lesson)
                
                return (
                  <tr key={lesson.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4">
                      <div>
                        <div className="text-sm font-medium text-gray-900">{lesson.title}</div>
                        {lesson.description && (
                          <div className="text-sm text-gray-500 line-clamp-1">{lesson.description}</div>
                        )}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`px-2 py-1 inline-flex items-center text-xs leading-5 font-semibold rounded-full ${getLessonTypeColor(lessonType)}`}>
                        {getLessonTypeIcon(lessonType)}
                        <span className="ml-1">{lessonType}</span>
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`px-2 py-1 text-xs font-medium rounded border ${getDifficultyColor(lesson.difficulty || 'beginner')}`}>
                        {getDifficultyLabel(lesson.difficulty || 'beginner')}
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex flex-wrap gap-1">
                        {lesson.vocabulary_questions?.length > 0 && (
                          <span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-green-100 text-green-800">
                            単語 {lesson.vocabulary_questions.length}
                          </span>
                        )}
                        {lesson.key_phrases?.length > 0 && (
                          <span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-blue-100 text-blue-800">
                            フレーズ {lesson.key_phrases.length}
                          </span>
                        )}
                        {lesson.listening_exercises?.length > 0 && (
                          <span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-purple-100 text-purple-800">
                            <Headphones className="h-3 w-3 mr-1" />
                            リスニング
                          </span>
                        )}
                        {lesson.dialogues?.length > 0 && (
                          <span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-indigo-100 text-indigo-800">
                            対話 {lesson.dialogues.length}
                          </span>
                        )}
                        {lesson.application_exercises?.length > 0 && (
                          <span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-yellow-100 text-yellow-800">
                            応用
                          </span>
                        )}
                        {exerciseCount === 0 && (
                          <span className="text-xs text-gray-500">未設定</span>
                        )}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      <div className="flex items-center">
                        <Clock className="h-4 w-4 mr-1 text-gray-400" />
                        {lesson.estimated_minutes || 30}分
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${
                        lesson.is_active ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'
                      }`}>
                        {lesson.is_active ? 'アクティブ' : '非アクティブ'}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                      <Link
                        href={`/lessons/${lesson.id}/edit`}
                        className="text-indigo-600 hover:text-indigo-900 mr-4"
                        title="編集"
                      >
                        <Edit className="h-4 w-4 inline" />
                      </Link>
                      <button
                        className="text-red-600 hover:text-red-900"
                        onClick={() => handleDelete(lesson.id, lesson.title)}
                        title="削除"
                      >
                        <Trash2 className="h-4 w-4 inline" />
                      </button>
                    </td>
                  </tr>
                )
              })}
            </tbody>
          </table>
        )}
      </div>
    </div>
  )
} 