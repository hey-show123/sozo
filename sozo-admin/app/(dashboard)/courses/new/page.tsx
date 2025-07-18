'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase'
import { ArrowLeft } from 'lucide-react'
import Link from 'next/link'

export default function NewCoursePage() {
  const router = useRouter()
  const supabase = createClient()
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    difficulty: 'beginner',
    objectives: [''],
    prerequisites: [''],
    is_active: true
  })

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError(null)

    try {
      // 空の目標と前提条件をフィルタリング
      const objectives = formData.objectives.filter(obj => obj.trim())
      const prerequisites = formData.prerequisites.filter(prereq => prereq.trim())

      const { data, error: insertError } = await supabase
        .from('courses')
        .insert({
          title: formData.title,
          description: formData.description || null,
          difficulty: formData.difficulty,
          objectives: objectives.length > 0 ? objectives : null,
          prerequisites: prerequisites.length > 0 ? prerequisites : null,
          is_active: formData.is_active
        })
        .select()
        .single()

      if (insertError) {
        throw insertError
      }

      alert('コースを作成しました！')
      router.push('/courses')
      router.refresh()
    } catch (err) {
      console.error('Error creating course:', err)
      setError(err instanceof Error ? err.message : 'コースの作成に失敗しました')
    } finally {
      setLoading(false)
    }
  }

  const addObjective = () => {
    setFormData({
      ...formData,
      objectives: [...formData.objectives, '']
    })
  }

  const removeObjective = (index: number) => {
    if (formData.objectives.length > 1) {
      setFormData({
        ...formData,
        objectives: formData.objectives.filter((_, i) => i !== index)
      })
    }
  }

  const updateObjective = (index: number, value: string) => {
    const newObjectives = [...formData.objectives]
    newObjectives[index] = value
    setFormData({ ...formData, objectives: newObjectives })
  }

  const addPrerequisite = () => {
    setFormData({
      ...formData,
      prerequisites: [...formData.prerequisites, '']
    })
  }

  const removePrerequisite = (index: number) => {
    if (formData.prerequisites.length > 1) {
      setFormData({
        ...formData,
        prerequisites: formData.prerequisites.filter((_, i) => i !== index)
      })
    }
  }

  const updatePrerequisite = (index: number, value: string) => {
    const newPrerequisites = [...formData.prerequisites]
    newPrerequisites[index] = value
    setFormData({ ...formData, prerequisites: newPrerequisites })
  }

  return (
    <div className="p-8">
      <div className="mb-8">
        <Link
          href="/courses"
          className="inline-flex items-center text-sm text-gray-500 hover:text-gray-700"
        >
          <ArrowLeft className="h-4 w-4 mr-1" />
          コース一覧に戻る
        </Link>
        <h1 className="text-3xl font-bold text-gray-900 mt-2">新しいコースを作成</h1>
      </div>

      {error && (
        <div className="mb-4 rounded-md bg-red-50 p-4">
          <div className="flex">
            <div className="ml-3">
              <h3 className="text-sm font-medium text-red-800">エラー</h3>
              <div className="mt-2 text-sm text-red-700">{error}</div>
            </div>
          </div>
        </div>
      )}

      <form onSubmit={handleSubmit} className="space-y-8 bg-white shadow rounded-lg p-6">
        {/* 基本情報 */}
        <div>
          <h2 className="text-lg font-medium text-gray-900 mb-4">基本情報</h2>
          <div className="grid grid-cols-1 gap-6">
            <div>
              <label htmlFor="title" className="block text-sm font-medium text-gray-700">
                コース名 *
              </label>
              <input
                type="text"
                name="title"
                id="title"
                required
                value={formData.title}
                onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                placeholder="例: ビジネス英会話マスターコース"
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
              />
            </div>

            <div>
              <label htmlFor="description" className="block text-sm font-medium text-gray-700">
                説明
              </label>
              <textarea
                name="description"
                id="description"
                rows={3}
                value={formData.description}
                onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                placeholder="コースの概要や学習内容を説明してください"
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
              />
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <label htmlFor="difficulty" className="block text-sm font-medium text-gray-700">
                  難易度
                </label>
                <select
                  id="difficulty"
                  name="difficulty"
                  value={formData.difficulty}
                  onChange={(e) => setFormData({ ...formData, difficulty: e.target.value })}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                >
                  <option value="beginner">初級</option>
                  <option value="elementary">初中級</option>
                  <option value="intermediate">中級</option>
                  <option value="advanced">上級</option>
                </select>
              </div>

              <div>
                <label htmlFor="is_active" className="block text-sm font-medium text-gray-700">
                  ステータス
                </label>
                <select
                  id="is_active"
                  name="is_active"
                  value={formData.is_active.toString()}
                  onChange={(e) => setFormData({ ...formData, is_active: e.target.value === 'true' })}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                >
                  <option value="true">アクティブ</option>
                  <option value="false">非アクティブ</option>
                </select>
              </div>
            </div>
          </div>
        </div>

        {/* 学習目標 */}
        <div>
          <h2 className="text-lg font-medium text-gray-900 mb-4">学習目標</h2>
          <p className="text-sm text-gray-500 mb-4">このコースで達成したい目標を設定してください</p>
          {formData.objectives.map((objective, index) => (
            <div key={index} className="flex gap-2 mb-2">
              <input
                type="text"
                value={objective}
                onChange={(e) => updateObjective(index, e.target.value)}
                placeholder="例: ビジネスシーンでの適切な英語表現を習得する"
                className="flex-1 rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
              />
              {formData.objectives.length > 1 && (
                <button
                  type="button"
                  onClick={() => removeObjective(index)}
                  className="px-3 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50"
                >
                  削除
                </button>
              )}
            </div>
          ))}
          <button
            type="button"
            onClick={addObjective}
            className="mt-2 inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-indigo-700 bg-indigo-100 hover:bg-indigo-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
          >
            学習目標を追加
          </button>
        </div>

        {/* 前提条件 */}
        <div>
          <h2 className="text-lg font-medium text-gray-900 mb-4">前提条件</h2>
          <p className="text-sm text-gray-500 mb-4">このコースを始める前に必要な知識やスキル</p>
          {formData.prerequisites.map((prerequisite, index) => (
            <div key={index} className="flex gap-2 mb-2">
              <input
                type="text"
                value={prerequisite}
                onChange={(e) => updatePrerequisite(index, e.target.value)}
                placeholder="例: 基本的な英語の読み書きができる"
                className="flex-1 rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
              />
              {formData.prerequisites.length > 1 && (
                <button
                  type="button"
                  onClick={() => removePrerequisite(index)}
                  className="px-3 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50"
                >
                  削除
                </button>
              )}
            </div>
          ))}
          <button
            type="button"
            onClick={addPrerequisite}
            className="mt-2 inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-indigo-700 bg-indigo-100 hover:bg-indigo-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
          >
            前提条件を追加
          </button>
        </div>

        <div className="flex justify-end space-x-3">
          <Link
            href="/courses"
            className="bg-white py-2 px-4 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
          >
            キャンセル
          </Link>
          <button
            type="submit"
            disabled={loading}
            className="inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {loading ? '作成中...' : 'コースを作成'}
          </button>
        </div>
      </form>
    </div>
  )
} 