import os
from typing import List, Optional
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    PROJECT_NAME: str = "Journal it (صَحِّف) API"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    
    # Environment
    NODE_ENV: str = "development"
    APP_ENV: str = "local"
    API_BASE_URL: str = "http://localhost:8000"
    NEXT_PUBLIC_APP_URL: str = "http://localhost:3000"
    
    # Security
    JWT_SECRET_KEY: str = "dev_jwt_secret_change_in_production_32chars"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 15
    SESSION_SECRET: str = "dev_session_cookie_secret_minimum_32chars"
    # Base64 encoded 256-bit key for AES-256-GCM vault
    VAULT_MASTER_KEY_B64: str = "c3VwZXJfc2VjcmV0XzI1Nl9iaXRfbWFzdGVyX2tleV9mb3JfZ2NtIQ=="
    
    # Database
    DATABASE_URL: str = "sqlite:///./journal_it.db"
    
    # Object Storage (MinIO / S3 / Local fallback)
    S3_ENDPOINT_URL: str = "http://localhost:9000"
    S3_ACCESS_KEY: str = "minioadmin"
    S3_SECRET_KEY: str = "minioadminpassword"
    S3_BUCKET_NAME: str = "journalit-media"
    S3_REGION: str = "us-east-1"
    STORAGE_LOCAL_DIR: str = "./storage_uploads"
    
    # Google Gemini
    GEMINI_API_KEY: Optional[str] = None
    GEMINI_MODEL_DEFAULT: str = "gemini-3.8-flash"
    GEMINI_MODEL_FALLBACK: str = "gemini-3.8-flash"
    
    # Google Docs OAuth2
    GOOGLE_CLIENT_ID: Optional[str] = None
    GOOGLE_CLIENT_SECRET: Optional[str] = None
    GOOGLE_REDIRECT_URI: str = "http://localhost:8000/api/v1/auth/google/callback"
    
    # CORS
    BACKEND_CORS_ORIGINS: List[str] = [
        "http://localhost:3000",
        "http://127.0.0.1:3000",
        "http://localhost:8000",
        "http://127.0.0.1:8000"
    ]

    model_config = SettingsConfigDict(
        env_file=".env",
        case_sensitive=True,
        extra="allow"
    )

settings = Settings()
