from typing import Optional, List, Dict, Any
from datetime import datetime
from pydantic import BaseModel, EmailStr, Field

class LoginRequest(BaseModel):
    email: EmailStr
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_id: str
    email: str
    full_name: str
    role: str
    preferred_language: str
    preferred_theme: str

class UserPreferencesUpdate(BaseModel):
    preferred_language: Optional[str] = Field(None, pattern="^(ar|en)$")
    preferred_theme: Optional[str] = Field(None, pattern="^(light|dark|system)$")

class UserProfileResponse(BaseModel):
    id: str
    tenant_id: str
    email: str
    full_name: str
    role: str
    preferred_language: str
    preferred_theme: str
    is_active: bool
    created_at: datetime
    updated_at: datetime

class PresignUploadRequest(BaseModel):
    filename: str
    content_type: str
    file_size_bytes: int

class PresignUploadResponse(BaseModel):
    interview_id: str
    upload_url: str
    media_url: str
    expires_in_seconds: int

class ProcessInterviewRequest(BaseModel):
    interview_id: str
    title: str = Field(..., min_length=2, max_length=500)
    language: str = Field("ar", pattern="^(ar|en)$")
    editorial_style: str = "inverted_pyramid"
    custom_byline: Optional[str] = None
    dateline: Optional[str] = None
    protect_confidential_sources: Optional[bool] = False

class ProcessInterviewResponse(BaseModel):
    interview_id: str
    task_id: str
    status: str
    estimated_seconds: int
    status_endpoint: str

class InterviewStatusResponse(BaseModel):
    interview_id: str
    status: str
    progress_percent: int
    current_stage_label: str
    error_message: Optional[str] = None
    article_id: Optional[str] = None

class DiarizedSegmentSchema(BaseModel):
    speaker: str
    timestamp: str
    text: str

class KeyQuoteSchema(BaseModel):
    speaker: str
    timestamp: str
    quote: str

class ArticleResponse(BaseModel):
    article_id: str
    interview_id: str
    headline: str
    subhead: Optional[str] = None
    byline: str
    dateline: str
    lead_paragraph: str
    nut_graph: str
    body_markdown: str
    body_html: str
    key_quotes: Optional[List[Dict[str, Any]]] = None
    language: str
    editorial_style: str
    word_count: int
    created_at: datetime

class TrackShareRequest(BaseModel):
    export_type: str = Field(..., pattern="^(clipboard|native_share|docx|google_docs)$")
    destination_url: Optional[str] = None

class GoogleDocsExportResponse(BaseModel):
    google_doc_id: str
    google_doc_url: str
    title: str

class GeminiKeyUpdateRequest(BaseModel):
    api_key: str = Field(..., min_length=10)

class GeminiKeyStatusResponse(BaseModel):
    is_configured: bool
    provider: str
    key_preview: Optional[str] = None
