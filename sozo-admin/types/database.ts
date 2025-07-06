export type UserRole = 'super_admin' | 'admin' | 'viewer' | 'learner'

export interface Organization {
  id: string
  name: string
  description?: string
  created_at?: string
  updated_at?: string
}

export interface UserOrganizationRole {
  id: string
  user_id: string
  organization_id: string
  role: UserRole
  created_at?: string
  updated_at?: string
  organizations?: Organization
}

export interface Course {
  id: string
  title: string
  description?: string
  difficulty_level: number
  category: string
  image_url?: string
  estimated_hours?: number
  prerequisites: string[]
  is_active: boolean
  created_at?: string
  updated_at?: string
}

export interface Module {
  id: string
  course_id: string
  title: string
  description?: string
  order_index: number
  unlock_requirements: Record<string, any>
  estimated_minutes?: number
  is_active: boolean
  created_at?: string
  updated_at?: string
}

export interface Lesson {
  id: string
  module_id?: string
  title: string
  description?: string
  level: number
  order?: number
  lesson_type?: string
  difficulty_score?: number
  target_phrases: string[]
  grammar_points: string[]
  cultural_notes?: string
  created_at?: string
  updated_at?: string
}

export interface LessonActivity {
  id: string
  lesson_id: string
  activity_type: string
  order_index: number
  content: Record<string, any>
  audio_url?: string
  estimated_minutes?: number
  success_criteria: Record<string, any>
  created_at?: string
  updated_at?: string
}

export interface KeyPhrase {
  phrase: string
  phonetic?: string
  meaning: string
  usage?: string
  examples: string[]
  audio_url?: string
}

export interface GrammarPoint {
  point: string
  explanation: string
  examples: string[]
  exercises: Exercise[]
}

export interface Exercise {
  question: string
  options?: string[]
  answer: string
  explanation?: string
}

export interface ConversationScenario {
  situation: string
  location: string
  aiRole: string
  userRole: string
  context: string
  suggestedTopics: string[]
} 