'use client'

import { useState, useEffect } from 'react'
import Link from 'next/link'
import { createClient } from '@/lib/supabase'
import { Plus, Pencil, Trash2, GraduationCap } from 'lucide-react'

interface Course {
  id: string
  title: string
  description: string | null
  difficulty: string
  is_active: boolean
  created_at: string
  updated_at: string
  module_count?: number
}

export default function CoursesPage() {
  const [courses, setCourses] = useState<Course[]>([])
  const [loading, setLoading] = useState(true)
  const supabase = createClient()

  useEffect(() => {
    loadCourses()
  }, [])

  const loadCourses = async () => {
    try {
      // コース一覧を取得
      const { data: coursesData, error: coursesError } = await supabase
        .from('courses')
        .select('*')
        .order('created_at', { ascending: false })

      if (coursesError) throw coursesError

      // 各コースのモジュール数を取得
      if (coursesData) {
        const coursesWithCount = await Promise.all(
          coursesData.map(async (course) => {
            const { count } = await supabase
              .from('modules')
              .select('*', { count: 'exact', head: true })
              .eq('course_id', course.id)
            
            return {
              ...course,
              module_count: count || 0
            }
          })
        )
        setCourses(coursesWithCount)
      }
    } catch (error) {
      console.error('Error loading courses:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleDelete = async (id: string) => {
    if (!confirm('このコースを削除してもよろしいですか？関連するモジュールとレッスンも削除されます。')) {
      return
    }

    try {
      const { error } = await supabase
        .from('courses')
        .delete()
        .eq('id', id)

      if (error) throw error

      alert('コースを削除しました')
      loadCourses()
    } catch (error) {
      console.error('Error deleting course:', error)
      alert('コースの削除に失敗しました')
    }
  }

  const getDifficultyLabel = (difficulty: string) => {
    const labels: { [key: string]: string } = {
      beginner: '初級',
      elementary: '初中級',
      intermediate: '中級',
      advanced: '上級'
    }
    return labels[difficulty] || difficulty
  }

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="text-gray-500">読み込み中...</div>
      </div>
    )
  }

  return (
    <div className="p-8">
      <div className="mb-8 flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">コース管理</h1>
          <p className="mt-2 text-gray-600">学習コースの作成と管理</p>
        </div>
        <Link
          href="/courses/new"
          className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
        >
          <Plus className="h-5 w-5 mr-2" />
          新しいコース
        </Link>
      </div>

      {courses.length === 0 ? (
        <div className="bg-white shadow rounded-lg p-12 text-center">
          <GraduationCap className="h-12 w-12 text-gray-400 mx-auto mb-4" />
          <p className="text-gray-500 mb-4">まだコースがありません</p>
          <Link
            href="/courses/new"
            className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-indigo-700 bg-indigo-100 hover:bg-indigo-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
          >
            最初のコースを作成
          </Link>
        </div>
      ) : (
        <div className="bg-white shadow rounded-lg overflow-hidden">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  コース名
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  難易度
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  モジュール数
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  ステータス
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  作成日
                </th>
                <th className="relative px-6 py-3">
                  <span className="sr-only">アクション</span>
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {courses.map((course) => (
                <tr key={course.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div>
                      <div className="text-sm font-medium text-gray-900">
                        {course.title}
                      </div>
                      {course.description && (
                        <div className="text-sm text-gray-500">
                          {course.description}
                        </div>
                      )}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                      {getDifficultyLabel(course.difficulty)}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {course.module_count} モジュール
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                      course.is_active 
                        ? 'bg-green-100 text-green-800' 
                        : 'bg-gray-100 text-gray-800'
                    }`}>
                      {course.is_active ? 'アクティブ' : '非アクティブ'}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {new Date(course.created_at).toLocaleDateString('ja-JP')}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    <Link
                      href={`/courses/${course.id}/edit`}
                      className="text-indigo-600 hover:text-indigo-900 mr-4"
                    >
                      <Pencil className="h-4 w-4 inline" />
                    </Link>
                    <button
                      onClick={() => handleDelete(course.id)}
                      className="text-red-600 hover:text-red-900"
                    >
                      <Trash2 className="h-4 w-4 inline" />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
} 