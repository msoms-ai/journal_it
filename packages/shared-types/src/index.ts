/**
 * Shared Type Definitions for Journal it (جورنال إت)
 * AI-Powered Mobile & Web Investigative Journalism Studio for Voice & Video Interviews
 */

export type SupportedLanguage = 'ar' | 'en';
export type ThemePreference = 'light' | 'dark' | 'system';
export type UserRole = 'super_admin' | 'newsroom_editor' | 'senior_reporter' | 'contributor';
export type EditorialStyle = 'inverted_pyramid' | 'feature_story' | 'bullet_brief';
export type ProcessingStatus = 'uploaded' | 'transcribing' | 'synthesizing' | 'completed' | 'failed';
export type ExportChannel = 'clipboard' | 'native_share' | 'docx' | 'google_docs';

export interface TenantSettings {
  max_audio_minutes: number;
  byok_enabled: boolean;
  default_editorial_style?: EditorialStyle;
  retention_days?: number;
}

export interface Tenant {
  id: string;
  name: string;
  slug: string;
  subscription_tier: 'solo_reporter' | 'newsroom_desk' | 'enterprise_agency';
  settings: TenantSettings;
  created_at: string;
  updated_at: string;
}

export interface User {
  id: string;
  tenant_id: string;
  email: string;
  full_name: string;
  role: UserRole;
  preferred_language: SupportedLanguage;
  preferred_theme: ThemePreference;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface UserPreferencesUpdate {
  preferred_language?: SupportedLanguage;
  preferred_theme?: ThemePreference;
}

export interface PresignUploadRequest {
  filename: string;
  content_type: string;
  file_size_bytes: number;
}

export interface PresignUploadResponse {
  interview_id: string;
  upload_url: string;
  media_url: string;
  expires_in_seconds: number;
}

export interface ProcessInterviewRequest {
  interview_id: string;
  title: string;
  language: SupportedLanguage;
  editorial_style?: EditorialStyle;
  custom_byline?: string;
  dateline?: string;
  protect_confidential_sources?: boolean;
}

export interface ProcessInterviewResponse {
  interview_id: string;
  task_id: string;
  status: ProcessingStatus;
  estimated_seconds: number;
  status_endpoint: string;
}

export interface DiarizedSegment {
  speaker: string;
  timestamp: string;
  text: string;
  confidence?: number;
}

export interface Transcript {
  id: string;
  interview_id: string;
  raw_text: string;
  diarized_segments: DiarizedSegment[];
  word_count: number;
  created_at: string;
}

export interface KeyQuote {
  speaker: string;
  timestamp: string;
  quote: string;
}

export interface Article {
  id: string;
  interview_id: string;
  tenant_id: string;
  headline: string;
  subhead?: string;
  byline: string;
  dateline: string;
  lead_paragraph: string;
  nut_graph: string;
  body_markdown: string;
  body_html: string;
  key_quotes?: KeyQuote[];
  language: SupportedLanguage;
  editorial_style: EditorialStyle;
  word_count: number;
  created_at: string;
  updated_at: string;
}

export interface InterviewStatusResponse {
  interview_id: string;
  status: ProcessingStatus;
  progress_percent: number;
  current_stage_label: string;
  error_message?: string | null;
  article_id?: string;
}

export interface GoogleDocsExportResponse {
  google_doc_id: string;
  google_doc_url: string;
  title: string;
}

export interface GeminiKeyStatusResponse {
  is_configured: boolean;
  provider: string;
  key_preview?: string;
}
