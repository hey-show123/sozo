'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase'
import { ArrowLeft, Plus, Trash2, GripVertical } from 'lucide-react'
import Link from 'next/link'
import { 
  Lesson, 
  KeyPhrase, 
  Dialogue, 
  VocabularyQuestion, 
  ListeningExercise,
  ApplicationExercise,
  ConversationScenario 
} from '@/types/database'

interface PageProps {
  params: {
    id: string
  }
}

export default function EditLessonPage({ params }: PageProps) {
  const router = useRouter()
  const supabase = createClient()
  const [loading, setLoading] = useState(false)
  const [loadingLesson, setLoadingLesson] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [activeTab, setActiveTab] = useState('basic')
  
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    type: 'conversation' as const,
    difficulty: 'beginner' as const,
    estimated_minutes: 30,
    character_id: 'sarah',
    objectives: [''],
    key_phrases: [{ 
      phrase: '', 
      meaning: '', 
      usage: '', 
      examples: [''] 
    }] as KeyPhrase[],
    dialogues: [{
      speaker: 'ai' as const,
      text: '',
      translation: ''
    }] as Dialogue[],
    vocabulary_questions: [{
      word: '',
      meaning: '',
      options: ['', '', '', ''],
      correct_answer: '',
      hint: ''
    }] as VocabularyQuestion[],
    listening_exercises: [{
      type: 'comprehension' as const,
      audio_text: '',
      questions: [{
        question: '',
        options: ['', '', '', ''],
        correct_answer: ''
      }],
      hints: ['']
    }] as ListeningExercise[],
    application_exercises: [{
      scenario: '',
      task: '',
      hints: [''],
      sample_responses: [''],
      evaluation_criteria: ['']
    }] as ApplicationExercise[],
    scenario: {
      situation: '',
      location: '',
      aiRole: '',
      userRole: '',
      context: '',
      suggestedTopics: ['']
    } as ConversationScenario,
    is_active: true
  })

  // レッスンデータを読み込む
  useEffect(() => {
    const loadLesson = async () => {
      try {
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) {
          router.push('/login')
          return
        }

        const { data: lesson, error: fetchError } = await supabase
          .from('lessons')
          .select('*')
          .eq('id', params.id)
          .single()

        if (fetchError) {
          throw fetchError
        }

        if (!lesson) {
          throw new Error('レッスンが見つかりません')
        }

        // データをフォームにセット
        setFormData({
          title: lesson.title || '',
          description: lesson.description || '',
          type: lesson.type || lesson.lesson_type || 'conversation',
          difficulty: lesson.difficulty || 'beginner',
          estimated_minutes: lesson.estimated_minutes || 30,
          character_id: lesson.character_id || 'sarah',
          objectives: lesson.objectives?.length > 0 ? lesson.objectives : [''],
          key_phrases: lesson.key_phrases?.length > 0 
            ? lesson.key_phrases 
            : [{ phrase: '', meaning: '', usage: '', examples: [''] }],
          dialogues: lesson.dialogues?.length > 0
            ? lesson.dialogues
            : [{ speaker: 'ai', text: '', translation: '' }],
          vocabulary_questions: lesson.vocabulary_questions?.length > 0
            ? lesson.vocabulary_questions
            : [{ word: '', meaning: '', options: ['', '', '', ''], correct_answer: '', hint: '' }],
          listening_exercises: lesson.listening_exercises?.length > 0
            ? lesson.listening_exercises
            : [{
                type: 'comprehension',
                audio_text: '',
                questions: [{ question: '', options: ['', '', '', ''], correct_answer: '' }],
                hints: ['']
              }],
          application_exercises: lesson.application_exercises?.length > 0
            ? lesson.application_exercises
            : [{
                scenario: '',
                task: '',
                hints: [''],
                sample_responses: [''],
                evaluation_criteria: ['']
              }],
          scenario: lesson.scenario || {
            situation: '',
            location: '',
            aiRole: '',
            userRole: '',
            context: '',
            suggestedTopics: ['']
          },
          is_active: lesson.is_active ?? true
        })
      } catch (err) {
        console.error('Error loading lesson:', err)
        setError(err instanceof Error ? err.message : 'レッスンの読み込みに失敗しました')
      } finally {
        setLoadingLesson(false)
      }
    }

    loadLesson()
  }, [params.id, router, supabase])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError(null)

    try {
      // 空の項目をフィルタリング
      const objectives = formData.objectives.filter(obj => obj.trim())
      const key_phrases = formData.key_phrases
        .filter(kp => kp.phrase.trim())
        .map(kp => ({
          ...kp,
          examples: kp.examples?.filter(ex => ex.trim()) || []
        }))

      const dialogues = formData.dialogues
        .filter(d => d.text.trim())

      const vocabulary_questions = formData.vocabulary_questions
        .filter(vq => vq.word.trim())
        .map(vq => ({
          ...vq,
          options: vq.options.filter(opt => opt.trim())
        }))

      const listening_exercises = formData.listening_exercises
        .filter(le => le.audio_text.trim())
        .map(le => ({
          ...le,
          questions: le.questions?.filter(q => q.question.trim()) || [],
          hints: le.hints?.filter(h => h.trim()) || []
        }))

      const application_exercises = formData.application_exercises
        .filter(ae => ae.scenario.trim() && ae.task.trim())
        .map(ae => ({
          ...ae,
          hints: ae.hints.filter(h => h.trim()),
          sample_responses: ae.sample_responses.filter(sr => sr.trim()),
          evaluation_criteria: ae.evaluation_criteria.filter(ec => ec.trim())
        }))

      const { error: updateError } = await supabase
        .from('lessons')
        .update({
          title: formData.title,
          description: formData.description,
          type: formData.type,
          lesson_type: formData.type, // 互換性のため
          difficulty: formData.difficulty,
          estimated_minutes: formData.estimated_minutes,
          character_id: formData.character_id,
          objectives: objectives.length > 0 ? objectives : null,
          key_phrases: key_phrases.length > 0 ? key_phrases : null,
          dialogues: dialogues.length > 0 ? dialogues : null,
          vocabulary_questions: vocabulary_questions.length > 0 ? vocabulary_questions : null,
          listening_exercises: listening_exercises.length > 0 ? listening_exercises : null,
          application_exercises: application_exercises.length > 0 ? application_exercises : null,
          scenario: formData.type === 'conversation' ? formData.scenario : null,
          is_active: formData.is_active,
          updated_at: new Date().toISOString()
        })
        .eq('id', params.id)

      if (updateError) {
        throw updateError
      }

      alert('レッスンを更新しました！')
      router.push('/lessons')
      router.refresh()
    } catch (err) {
      console.error('Error updating lesson:', err)
      setError(err instanceof Error ? err.message : 'レッスンの更新に失敗しました')
    } finally {
      setLoading(false)
    }
  }

  // タブの設定
  const tabs = [
    { id: 'basic', label: '基本情報' },
    { id: 'vocabulary', label: '単語練習' },
    { id: 'keyphrases', label: 'キーフレーズ練習' },
    { id: 'listening', label: 'リスニング練習' },
    { id: 'dialogue', label: 'ダイアログ練習' },
    { id: 'application', label: '応用練習' },
    { id: 'ai-conversation', label: 'AI会話実践' },
  ]

  if (loadingLesson) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="text-gray-500">レッスンを読み込み中...</div>
      </div>
    )
  }

  return (
    <div className="p-8">
      <div className="mb-8">
        <Link
          href="/lessons"
          className="inline-flex items-center text-sm text-gray-500 hover:text-gray-700"
        >
          <ArrowLeft className="h-4 w-4 mr-1" />
          レッスン一覧に戻る
        </Link>
        <h1 className="text-3xl font-bold text-gray-900 mt-2">レッスン編集</h1>
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

      <form onSubmit={handleSubmit}>
        {/* タブナビゲーション */}
        <div className="border-b border-gray-200 mb-6">
          <nav className="-mb-px flex space-x-8">
            {tabs.map((tab) => (
              <button
                key={tab.id}
                type="button"
                onClick={() => setActiveTab(tab.id)}
                className={`
                  py-2 px-1 border-b-2 font-medium text-sm
                  ${activeTab === tab.id
                    ? 'border-indigo-500 text-indigo-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                  }
                `}
              >
                {tab.label}
              </button>
            ))}
          </nav>
        </div>

        <div className="bg-white shadow rounded-lg p-6">
          {/* 基本情報タブ */}
          {activeTab === 'basic' && (
            <div className="space-y-6">
          <h2 className="text-lg font-medium text-gray-900 mb-4">基本情報</h2>
              
            <div>
              <label htmlFor="title" className="block text-sm font-medium text-gray-700">
                タイトル *
              </label>
              <input
                type="text"
                name="title"
                id="title"
                required
                value={formData.title}
                onChange={(e) => setFormData({ ...formData, title: e.target.value })}
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
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
              />
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                  <label htmlFor="type" className="block text-sm font-medium text-gray-700">
                  レッスンタイプ
                </label>
                <select
                    id="type"
                    name="type"
                    value={formData.type}
                    onChange={(e) => setFormData({ ...formData, type: e.target.value as any })}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                >
                  <option value="conversation">会話</option>
                  <option value="pronunciation">発音</option>
                  <option value="vocabulary">語彙</option>
                  <option value="grammar">文法</option>
                    <option value="review">復習</option>
                </select>
              </div>

              <div>
                <label htmlFor="difficulty" className="block text-sm font-medium text-gray-700">
                  難易度
                </label>
                <select
                  id="difficulty"
                  name="difficulty"
                  value={formData.difficulty}
                    onChange={(e) => setFormData({ ...formData, difficulty: e.target.value as any })}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                >
                  <option value="beginner">初級</option>
                  <option value="elementary">初中級</option>
                  <option value="intermediate">中級</option>
                  <option value="advanced">上級</option>
                </select>
              </div>
            </div>

            <div className="grid grid-cols-3 gap-4">
              <div>
                <label htmlFor="estimated_minutes" className="block text-sm font-medium text-gray-700">
                  想定時間（分）
                </label>
                <input
                  type="number"
                  name="estimated_minutes"
                  id="estimated_minutes"
                  min="5"
                  max="120"
                  value={formData.estimated_minutes}
                  onChange={(e) => setFormData({ ...formData, estimated_minutes: parseInt(e.target.value) || 30 })}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                />
              </div>

              <div>
                <label htmlFor="character_id" className="block text-sm font-medium text-gray-700">
                  キャラクター
                </label>
                <select
                  id="character_id"
                  name="character_id"
                  value={formData.character_id}
                  onChange={(e) => setFormData({ ...formData, character_id: e.target.value })}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                >
                  <option value="sarah">Sarah - 英語学習コーディネーター</option>
                  <option value="maya">Maya - フレンドリーな会話パートナー</option>
                  <option value="alex">Alex - ビジネス英語講師</option>
                  <option value="emma">Emma - 発音スペシャリスト</option>
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

        {/* 学習目標 */}
        <div>
                <h3 className="text-md font-medium text-gray-900 mb-2">学習目標</h3>
          {formData.objectives.map((objective, index) => (
            <div key={index} className="flex gap-2 mb-2">
              <input
                type="text"
                value={objective}
                      onChange={(e) => {
                        const newObjectives = [...formData.objectives]
                        newObjectives[index] = e.target.value
                        setFormData({ ...formData, objectives: newObjectives })
                      }}
                placeholder="学習目標を入力"
                className="flex-1 rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
              />
              {formData.objectives.length > 1 && (
                <button
                  type="button"
                        onClick={() => {
                          setFormData({
                            ...formData,
                            objectives: formData.objectives.filter((_, i) => i !== index)
                          })
                        }}
                        className="p-2 text-red-600 hover:text-red-700"
                      >
                        <Trash2 className="h-4 w-4" />
                </button>
              )}
            </div>
          ))}
          <button
            type="button"
                  onClick={() => setFormData({ ...formData, objectives: [...formData.objectives, ''] })}
                  className="mt-2 inline-flex items-center px-3 py-1.5 border border-transparent text-xs font-medium rounded text-indigo-700 bg-indigo-100 hover:bg-indigo-200"
          >
                  <Plus className="h-3 w-3 mr-1" />
                  追加
          </button>
        </div>
            </div>
          )}

          {/* 単語練習タブ */}
          {activeTab === 'vocabulary' && (
            <VocabularyTab formData={formData} setFormData={setFormData} />
          )}

          {/* キーフレーズ練習タブ */}
          {activeTab === 'keyphrases' && (
            <KeyPhrasesTab formData={formData} setFormData={setFormData} />
          )}

          {/* リスニング練習タブ */}
          {activeTab === 'listening' && (
            <ListeningTab formData={formData} setFormData={setFormData} />
          )}

          {/* ダイアログ練習タブ */}
          {activeTab === 'dialogue' && (
            <DialogueTab formData={formData} setFormData={setFormData} />
          )}

          {/* 応用練習タブ */}
          {activeTab === 'application' && (
            <ApplicationTab formData={formData} setFormData={setFormData} />
          )}

          {/* AI会話実践タブ */}
          {activeTab === 'ai-conversation' && (
            <AIConversationTab formData={formData} setFormData={setFormData} />
          )}
        </div>

        {/* 保存ボタン */}
        <div className="mt-6 flex justify-end space-x-3">
          <Link
            href="/lessons"
            className="bg-white py-2 px-4 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 hover:bg-gray-50"
          >
            キャンセル
          </Link>
          <button
            type="submit"
            disabled={loading}
            className="inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {loading ? '更新中...' : 'レッスンを更新'}
          </button>
        </div>
      </form>
    </div>
  )
}

// 単語練習タブコンポーネント
function VocabularyTab({ formData, setFormData }: any) {
  return (
    <div className="space-y-6">
      <h2 className="text-lg font-medium text-gray-900 mb-4">単語練習</h2>
      
      {formData.vocabulary_questions.map((vq: VocabularyQuestion, index: number) => (
        <div key={index} className="border border-gray-200 rounded-lg p-4 space-y-4">
          <div className="flex justify-between items-start">
            <h3 className="text-sm font-medium text-gray-900">問題 {index + 1}</h3>
            {formData.vocabulary_questions.length > 1 && (
              <button
                type="button"
                onClick={() => {
                  setFormData({
                    ...formData,
                    vocabulary_questions: formData.vocabulary_questions.filter((_: any, i: number) => i !== index)
                  })
                }}
                className="text-red-600 hover:text-red-700"
              >
                <Trash2 className="h-4 w-4" />
              </button>
            )}
          </div>

          <div className="grid grid-cols-2 gap-4">
        <div>
              <label className="block text-sm font-medium text-gray-700">単語</label>
              <input
                type="text"
                value={vq.word}
                onChange={(e) => {
                  const newVQ = [...formData.vocabulary_questions]
                  newVQ[index] = { ...newVQ[index], word: e.target.value }
                  setFormData({ ...formData, vocabulary_questions: newVQ })
                }}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">意味（正解）</label>
              <input
                type="text"
                value={vq.meaning}
                onChange={(e) => {
                  const newVQ = [...formData.vocabulary_questions]
                  newVQ[index] = { ...newVQ[index], meaning: e.target.value, correct_answer: e.target.value }
                  setFormData({ ...formData, vocabulary_questions: newVQ })
                }}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">選択肢（4つ）</label>
            <div className="grid grid-cols-2 gap-2">
              {vq.options.map((option: string, optIndex: number) => (
                <input
                  key={optIndex}
                  type="text"
                  value={option}
                  onChange={(e) => {
                    const newVQ = [...formData.vocabulary_questions]
                    const newOptions = [...newVQ[index].options]
                    newOptions[optIndex] = e.target.value
                    newVQ[index] = { ...newVQ[index], options: newOptions }
                    setFormData({ ...formData, vocabulary_questions: newVQ })
                  }}
                  placeholder={`選択肢 ${optIndex + 1}`}
                  className="rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                />
              ))}
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">ヒント（オプション）</label>
            <input
              type="text"
              value={vq.hint || ''}
              onChange={(e) => {
                const newVQ = [...formData.vocabulary_questions]
                newVQ[index] = { ...newVQ[index], hint: e.target.value }
                setFormData({ ...formData, vocabulary_questions: newVQ })
              }}
              placeholder="例：よく使われる動詞です"
              className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
            />
          </div>
        </div>
      ))}

      <button
        type="button"
        onClick={() => {
          setFormData({
            ...formData,
            vocabulary_questions: [...formData.vocabulary_questions, {
              word: '',
              meaning: '',
              options: ['', '', '', ''],
              correct_answer: '',
              hint: ''
            }]
          })
        }}
        className="inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-indigo-700 bg-indigo-100 hover:bg-indigo-200"
      >
        <Plus className="h-4 w-4 mr-1" />
        問題を追加
      </button>
    </div>
  )
}

// キーフレーズ練習タブコンポーネント
function KeyPhrasesTab({ formData, setFormData }: any) {
  return (
    <div className="space-y-6">
      <h2 className="text-lg font-medium text-gray-900 mb-4">キーフレーズ練習</h2>
      
      {formData.key_phrases.map((kp: KeyPhrase, index: number) => (
        <div key={index} className="border border-gray-200 rounded-lg p-4 space-y-4">
          <div className="flex justify-between items-start">
            <h3 className="text-sm font-medium text-gray-900">キーフレーズ {index + 1}</h3>
            {formData.key_phrases.length > 1 && (
              <button
                type="button"
                onClick={() => {
                  setFormData({
                    ...formData,
                    key_phrases: formData.key_phrases.filter((_: any, i: number) => i !== index)
                  })
                }}
                className="text-red-600 hover:text-red-700"
              >
                <Trash2 className="h-4 w-4" />
              </button>
            )}
          </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700">フレーズ</label>
                  <input
                    type="text"
              value={kp.phrase}
              onChange={(e) => {
                const newKP = [...formData.key_phrases]
                newKP[index] = { ...newKP[index], phrase: e.target.value }
                setFormData({ ...formData, key_phrases: newKP })
              }}
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700">意味</label>
                  <input
                    type="text"
              value={kp.meaning}
              onChange={(e) => {
                const newKP = [...formData.key_phrases]
                newKP[index] = { ...newKP[index], meaning: e.target.value }
                setFormData({ ...formData, key_phrases: newKP })
              }}
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                  />
                </div>

                <div>
            <label className="block text-sm font-medium text-gray-700">使い方（オプション）</label>
                  <input
                    type="text"
              value={kp.usage || ''}
              onChange={(e) => {
                const newKP = [...formData.key_phrases]
                newKP[index] = { ...newKP[index], usage: e.target.value }
                setFormData({ ...formData, key_phrases: newKP })
              }}
              placeholder="例：ビジネスシーンでよく使われます"
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">例文</label>
            {kp.examples?.map((example: string, exIndex: number) => (
                    <div key={exIndex} className="flex gap-2 mb-2">
                      <input
                        type="text"
                        value={example}
                  onChange={(e) => {
                    const newKP = [...formData.key_phrases]
                    const newExamples = [...(newKP[index].examples || [])]
                    newExamples[exIndex] = e.target.value
                    newKP[index] = { ...newKP[index], examples: newExamples }
                    setFormData({ ...formData, key_phrases: newKP })
                  }}
                        placeholder="例文を入力"
                        className="flex-1 rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                      />
                {kp.examples && kp.examples.length > 1 && (
                        <button
                          type="button"
                    onClick={() => {
                      const newKP = [...formData.key_phrases]
                      newKP[index] = {
                        ...newKP[index],
                        examples: newKP[index].examples?.filter((_: any, i: number) => i !== exIndex) || []
                      }
                      setFormData({ ...formData, key_phrases: newKP })
                    }}
                    className="text-red-600 hover:text-red-700"
                  >
                    <Trash2 className="h-4 w-4" />
                        </button>
                      )}
                    </div>
                  ))}
                  <button
                    type="button"
              onClick={() => {
                const newKP = [...formData.key_phrases]
                newKP[index] = {
                  ...newKP[index],
                  examples: [...(newKP[index].examples || []), '']
                }
                setFormData({ ...formData, key_phrases: newKP })
              }}
                    className="text-sm text-indigo-600 hover:text-indigo-500"
                  >
              <Plus className="h-3 w-3 inline mr-1" />
                    例文を追加
                  </button>
                </div>
              </div>
      ))}

                <button
                  type="button"
        onClick={() => {
          setFormData({
            ...formData,
            key_phrases: [...formData.key_phrases, {
              phrase: '',
              meaning: '',
              usage: '',
              examples: ['']
            }]
          })
        }}
        className="inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-indigo-700 bg-indigo-100 hover:bg-indigo-200"
      >
        <Plus className="h-4 w-4 mr-1" />
        キーフレーズを追加
      </button>
    </div>
  )
}

// リスニング練習タブコンポーネント
function ListeningTab({ formData, setFormData }: any) {
  return (
    <div className="space-y-6">
      <h2 className="text-lg font-medium text-gray-900 mb-4">リスニング練習</h2>
      
      {formData.listening_exercises.map((le: ListeningExercise, index: number) => (
        <div key={index} className="border border-gray-200 rounded-lg p-4 space-y-4">
          <div className="flex justify-between items-start">
            <h3 className="text-sm font-medium text-gray-900">練習 {index + 1}</h3>
            {formData.listening_exercises.length > 1 && (
              <button
                type="button"
                onClick={() => {
                  setFormData({
                    ...formData,
                    listening_exercises: formData.listening_exercises.filter((_: any, i: number) => i !== index)
                  })
                }}
                className="text-red-600 hover:text-red-700"
              >
                <Trash2 className="h-4 w-4" />
                </button>
              )}
            </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">練習タイプ</label>
            <select
              value={le.type}
              onChange={(e) => {
                const newLE = [...formData.listening_exercises]
                newLE[index] = { ...newLE[index], type: e.target.value }
                setFormData({ ...formData, listening_exercises: newLE })
              }}
              className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
            >
              <option value="comprehension">内容理解</option>
              <option value="dictation">ディクテーション</option>
              <option value="fill_blank">穴埋め</option>
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">音声テキスト</label>
            <textarea
              rows={3}
              value={le.audio_text}
              onChange={(e) => {
                const newLE = [...formData.listening_exercises]
                newLE[index] = { ...newLE[index], audio_text: e.target.value }
                setFormData({ ...formData, listening_exercises: newLE })
              }}
              placeholder="音声で読み上げられるテキストを入力"
              className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
            />
          </div>

          {le.type === 'comprehension' && le.questions && (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">理解度確認問題</label>
              {le.questions.map((q: any, qIndex: number) => (
                <div key={qIndex} className="border border-gray-100 rounded p-3 mb-2 space-y-2">
                  <input
                    type="text"
                    value={q.question}
                    onChange={(e) => {
                      const newLE = [...formData.listening_exercises]
                      const newQuestions = [...(newLE[index].questions || [])]
                      newQuestions[qIndex] = { ...newQuestions[qIndex], question: e.target.value }
                      newLE[index] = { ...newLE[index], questions: newQuestions }
                      setFormData({ ...formData, listening_exercises: newLE })
                    }}
                    placeholder="質問"
                    className="w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                  />
                  <div className="grid grid-cols-2 gap-2">
                    {q.options.map((opt: string, optIndex: number) => (
                      <input
                        key={optIndex}
                        type="text"
                        value={opt}
                        onChange={(e) => {
                          const newLE = [...formData.listening_exercises]
                          const newQuestions = [...(newLE[index].questions || [])]
                          const newOptions = [...newQuestions[qIndex].options]
                          newOptions[optIndex] = e.target.value
                          newQuestions[qIndex] = { ...newQuestions[qIndex], options: newOptions }
                          newLE[index] = { ...newLE[index], questions: newQuestions }
                          setFormData({ ...formData, listening_exercises: newLE })
                        }}
                        placeholder={`選択肢 ${optIndex + 1}`}
                        className="rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                      />
                    ))}
                  </div>
                  <input
                    type="text"
                    value={q.correct_answer}
                    onChange={(e) => {
                      const newLE = [...formData.listening_exercises]
                      const newQuestions = [...(newLE[index].questions || [])]
                      newQuestions[qIndex] = { ...newQuestions[qIndex], correct_answer: e.target.value }
                      newLE[index] = { ...newLE[index], questions: newQuestions }
                      setFormData({ ...formData, listening_exercises: newLE })
                    }}
                    placeholder="正解"
                    className="w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                  />
                </div>
              ))}
            </div>
          )}

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">ヒント</label>
            {le.hints?.map((hint: string, hIndex: number) => (
              <div key={hIndex} className="flex gap-2 mb-2">
                <input
                  type="text"
                  value={hint}
                  onChange={(e) => {
                    const newLE = [...formData.listening_exercises]
                    const newHints = [...(newLE[index].hints || [])]
                    newHints[hIndex] = e.target.value
                    newLE[index] = { ...newLE[index], hints: newHints }
                    setFormData({ ...formData, listening_exercises: newLE })
                  }}
                  placeholder="ヒント"
                  className="flex-1 rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                />
              </div>
            ))}
          </div>
        </div>
      ))}

          <button
            type="button"
        onClick={() => {
          setFormData({
            ...formData,
            listening_exercises: [...formData.listening_exercises, {
              type: 'comprehension',
              audio_text: '',
              questions: [{ question: '', options: ['', '', '', ''], correct_answer: '' }],
              hints: ['']
            }]
          })
        }}
        className="inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-indigo-700 bg-indigo-100 hover:bg-indigo-200"
      >
        <Plus className="h-4 w-4 mr-1" />
        リスニング練習を追加
          </button>
        </div>
  )
}

// ダイアログ練習タブコンポーネント
function DialogueTab({ formData, setFormData }: any) {
  return (
    <div className="space-y-6">
          <h2 className="text-lg font-medium text-gray-900 mb-4">ダイアログ練習</h2>
          <p className="text-sm text-gray-500 mb-4">会話の流れを設定します。AIとユーザーの対話を順番に入力してください。</p>
      
      {formData.dialogues.map((dialogue: Dialogue, index: number) => (
        <div key={index} className="border border-gray-200 rounded-lg p-4 space-y-4">
          <div className="flex justify-between items-start">
            <div className="flex items-center space-x-2">
              <GripVertical className="h-4 w-4 text-gray-400" />
              <h3 className="text-sm font-medium text-gray-900">
                {dialogue.speaker === 'ai' ? 'AI' : 'ユーザー'} - ターン {index + 1}
              </h3>
            </div>
            {formData.dialogues.length > 1 && (
              <button
                type="button"
                onClick={() => {
                  setFormData({
                    ...formData,
                    dialogues: formData.dialogues.filter((_: any, i: number) => i !== index)
                  })
                }}
                className="text-red-600 hover:text-red-700"
              >
                <Trash2 className="h-4 w-4" />
              </button>
            )}
          </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700">話者</label>
                  <select
                    value={dialogue.speaker}
              onChange={(e) => {
                const newDialogues = [...formData.dialogues]
                newDialogues[index] = { ...newDialogues[index], speaker: e.target.value }
                setFormData({ ...formData, dialogues: newDialogues })
              }}
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                  >
                    <option value="ai">AI</option>
                    <option value="user">ユーザー</option>
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700">セリフ</label>
                  <input
                    type="text"
                    value={dialogue.text}
              onChange={(e) => {
                const newDialogues = [...formData.dialogues]
                newDialogues[index] = { ...newDialogues[index], text: e.target.value }
                setFormData({ ...formData, dialogues: newDialogues })
              }}
                    placeholder={dialogue.speaker === 'ai' ? '例: Good morning! How may I help you today?' : '例: I would like to order breakfast, please.'}
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700">日本語訳（オプション）</label>
                  <input
                    type="text"
              value={dialogue.translation || ''}
              onChange={(e) => {
                const newDialogues = [...formData.dialogues]
                newDialogues[index] = { ...newDialogues[index], translation: e.target.value }
                setFormData({ ...formData, dialogues: newDialogues })
              }}
                    placeholder={dialogue.speaker === 'ai' ? '例: おはようございます！何かお手伝いできることはありますか？' : '例: 朝食を注文したいのですが。'}
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                  />
                </div>
              </div>
      ))}

                <button
                  type="button"
        onClick={() => {
          setFormData({
            ...formData,
            dialogues: [...formData.dialogues, {
              speaker: formData.dialogues.length % 2 === 0 ? 'ai' : 'user',
              text: '',
              translation: ''
            }]
          })
        }}
        className="inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-indigo-700 bg-indigo-100 hover:bg-indigo-200"
      >
        <Plus className="h-4 w-4 mr-1" />
        ダイアログを追加
      </button>
    </div>
  )
}

// 応用練習タブコンポーネント
function ApplicationTab({ formData, setFormData }: any) {
  return (
    <div className="space-y-6">
      <h2 className="text-lg font-medium text-gray-900 mb-4">応用練習</h2>
      
      {formData.application_exercises.map((ae: ApplicationExercise, index: number) => (
        <div key={index} className="border border-gray-200 rounded-lg p-4 space-y-4">
          <div className="flex justify-between items-start">
            <h3 className="text-sm font-medium text-gray-900">練習 {index + 1}</h3>
            {formData.application_exercises.length > 1 && (
              <button
                type="button"
                onClick={() => {
                  setFormData({
                    ...formData,
                    application_exercises: formData.application_exercises.filter((_: any, i: number) => i !== index)
                  })
                }}
                className="text-red-600 hover:text-red-700"
              >
                <Trash2 className="h-4 w-4" />
              </button>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">シナリオ</label>
            <textarea
              rows={2}
              value={ae.scenario}
              onChange={(e) => {
                const newAE = [...formData.application_exercises]
                newAE[index] = { ...newAE[index], scenario: e.target.value }
                setFormData({ ...formData, application_exercises: newAE })
              }}
              placeholder="例：あなたは空港で搭乗手続きをしています"
              className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">タスク</label>
            <textarea
              rows={2}
              value={ae.task}
              onChange={(e) => {
                const newAE = [...formData.application_exercises]
                newAE[index] = { ...newAE[index], task: e.target.value }
                setFormData({ ...formData, application_exercises: newAE })
              }}
              placeholder="例：チェックインカウンターで搭乗券を受け取り、荷物を預けてください"
              className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">ヒント</label>
            {ae.hints.map((hint: string, hIndex: number) => (
              <div key={hIndex} className="flex gap-2 mb-2">
                <input
                  type="text"
                  value={hint}
                  onChange={(e) => {
                    const newAE = [...formData.application_exercises]
                    const newHints = [...newAE[index].hints]
                    newHints[hIndex] = e.target.value
                    newAE[index] = { ...newAE[index], hints: newHints }
                    setFormData({ ...formData, application_exercises: newAE })
                  }}
                  placeholder="ヒント"
                  className="flex-1 rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                />
                {ae.hints.length > 1 && (
                  <button
                    type="button"
                    onClick={() => {
                      const newAE = [...formData.application_exercises]
                      newAE[index] = {
                        ...newAE[index],
                        hints: newAE[index].hints.filter((_: any, i: number) => i !== hIndex)
                      }
                      setFormData({ ...formData, application_exercises: newAE })
                    }}
                    className="text-red-600 hover:text-red-700"
                  >
                    <Trash2 className="h-4 w-4" />
                </button>
              )}
            </div>
          ))}
          <button
            type="button"
              onClick={() => {
                const newAE = [...formData.application_exercises]
                newAE[index] = {
                  ...newAE[index],
                  hints: [...newAE[index].hints, '']
                }
                setFormData({ ...formData, application_exercises: newAE })
              }}
              className="text-sm text-indigo-600 hover:text-indigo-500"
            >
              <Plus className="h-3 w-3 inline mr-1" />
              ヒントを追加
          </button>
        </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">回答例</label>
            {ae.sample_responses.map((sr: string, srIndex: number) => (
              <div key={srIndex} className="flex gap-2 mb-2">
                <textarea
                  rows={2}
                  value={sr}
                  onChange={(e) => {
                    const newAE = [...formData.application_exercises]
                    const newSR = [...newAE[index].sample_responses]
                    newSR[srIndex] = e.target.value
                    newAE[index] = { ...newAE[index], sample_responses: newSR }
                    setFormData({ ...formData, application_exercises: newAE })
                  }}
                  placeholder="回答例"
                  className="flex-1 rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                />
                {ae.sample_responses.length > 1 && (
                  <button
                    type="button"
                    onClick={() => {
                      const newAE = [...formData.application_exercises]
                      newAE[index] = {
                        ...newAE[index],
                        sample_responses: newAE[index].sample_responses.filter((_: any, i: number) => i !== srIndex)
                      }
                      setFormData({ ...formData, application_exercises: newAE })
                    }}
                    className="text-red-600 hover:text-red-700"
                  >
                    <Trash2 className="h-4 w-4" />
                  </button>
                )}
              </div>
            ))}
            <button
              type="button"
              onClick={() => {
                const newAE = [...formData.application_exercises]
                newAE[index] = {
                  ...newAE[index],
                  sample_responses: [...newAE[index].sample_responses, '']
                }
                setFormData({ ...formData, application_exercises: newAE })
              }}
              className="text-sm text-indigo-600 hover:text-indigo-500"
            >
              <Plus className="h-3 w-3 inline mr-1" />
              回答例を追加
            </button>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">評価基準</label>
            {ae.evaluation_criteria.map((ec: string, ecIndex: number) => (
              <div key={ecIndex} className="flex gap-2 mb-2">
                <input
                  type="text"
                  value={ec}
                  onChange={(e) => {
                    const newAE = [...formData.application_exercises]
                    const newEC = [...newAE[index].evaluation_criteria]
                    newEC[ecIndex] = e.target.value
                    newAE[index] = { ...newAE[index], evaluation_criteria: newEC }
                    setFormData({ ...formData, application_exercises: newAE })
                  }}
                  placeholder="評価基準"
                  className="flex-1 rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                />
                {ae.evaluation_criteria.length > 1 && (
                  <button
                    type="button"
                    onClick={() => {
                      const newAE = [...formData.application_exercises]
                      newAE[index] = {
                        ...newAE[index],
                        evaluation_criteria: newAE[index].evaluation_criteria.filter((_: any, i: number) => i !== ecIndex)
                      }
                      setFormData({ ...formData, application_exercises: newAE })
                    }}
                    className="text-red-600 hover:text-red-700"
                  >
                    <Trash2 className="h-4 w-4" />
                  </button>
                )}
              </div>
            ))}
            <button
              type="button"
              onClick={() => {
                const newAE = [...formData.application_exercises]
                newAE[index] = {
                  ...newAE[index],
                  evaluation_criteria: [...newAE[index].evaluation_criteria, '']
                }
                setFormData({ ...formData, application_exercises: newAE })
              }}
              className="text-sm text-indigo-600 hover:text-indigo-500"
            >
              <Plus className="h-3 w-3 inline mr-1" />
              評価基準を追加
            </button>
          </div>
        </div>
      ))}

      <button
        type="button"
        onClick={() => {
          setFormData({
            ...formData,
            application_exercises: [...formData.application_exercises, {
              scenario: '',
              task: '',
              hints: [''],
              sample_responses: [''],
              evaluation_criteria: ['']
            }]
          })
        }}
        className="inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-indigo-700 bg-indigo-100 hover:bg-indigo-200"
      >
        <Plus className="h-4 w-4 mr-1" />
        応用練習を追加
      </button>
    </div>
  )
}

// AI会話実践タブコンポーネント
function AIConversationTab({ formData, setFormData }: any) {
  return (
    <div className="space-y-6">
      <h2 className="text-lg font-medium text-gray-900 mb-4">AI会話実践</h2>
      <p className="text-sm text-gray-500 mb-4">AI会話実践のシナリオ設定を行います。ユーザーがAIと自由に会話練習できます。</p>
      
      <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700">シチュエーション</label>
                <input
                  type="text"
                  value={formData.scenario.situation}
                  onChange={(e) => setFormData({
                    ...formData,
                    scenario: { ...formData.scenario, situation: e.target.value }
                  })}
                  placeholder="例: レストランでの注文"
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">場所</label>
                <input
                  type="text"
                  value={formData.scenario.location}
                  onChange={(e) => setFormData({
                    ...formData,
                    scenario: { ...formData.scenario, location: e.target.value }
                  })}
                  placeholder="例: カジュアルレストラン"
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700">AIの役割</label>
                  <input
                    type="text"
                    value={formData.scenario.aiRole}
                    onChange={(e) => setFormData({
                      ...formData,
                      scenario: { ...formData.scenario, aiRole: e.target.value }
                    })}
                    placeholder="例: ウェイター"
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700">ユーザーの役割</label>
                  <input
                    type="text"
                    value={formData.scenario.userRole}
                    onChange={(e) => setFormData({
                      ...formData,
                      scenario: { ...formData.scenario, userRole: e.target.value }
                    })}
                    placeholder="例: お客様"
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                  />
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">コンテキスト</label>
                <textarea
                  rows={3}
                  value={formData.scenario.context}
                  onChange={(e) => setFormData({
                    ...formData,
                    scenario: { ...formData.scenario, context: e.target.value }
                  })}
            placeholder="例: 友人とカジュアルなレストランで夕食を楽しみます。メニューを見ながら、料理について質問したり、注文したりします。"
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                />
              </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">推奨トピック</label>
          {formData.scenario.suggestedTopics.map((topic: string, index: number) => (
            <div key={index} className="flex gap-2 mb-2">
              <input
                type="text"
                value={topic}
                onChange={(e) => {
                  const newTopics = [...formData.scenario.suggestedTopics]
                  newTopics[index] = e.target.value
                  setFormData({
                    ...formData,
                    scenario: { ...formData.scenario, suggestedTopics: newTopics }
                  })
                }}
                placeholder="例: メニューについて質問する"
                className="flex-1 rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
              />
              {formData.scenario.suggestedTopics.length > 1 && (
                <button
                  type="button"
                  onClick={() => {
                    setFormData({
                      ...formData,
                      scenario: {
                        ...formData.scenario,
                        suggestedTopics: formData.scenario.suggestedTopics.filter((_: any, i: number) => i !== index)
                      }
                    })
                  }}
                  className="text-red-600 hover:text-red-700"
                >
                  <Trash2 className="h-4 w-4" />
                </button>
              )}
            </div>
          ))}
          <button
            type="button"
            onClick={() => {
              setFormData({
                ...formData,
                scenario: {
                  ...formData.scenario,
                  suggestedTopics: [...formData.scenario.suggestedTopics, '']
                }
              })
            }}
            className="text-sm text-indigo-600 hover:text-indigo-500"
          >
            <Plus className="h-3 w-3 inline mr-1" />
            トピックを追加
          </button>
        </div>
      </div>
    </div>
  )
} 