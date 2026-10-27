import uuid
from datetime import datetime
from sqlalchemy import (
    Column,
    String,
    Text,
    BigInteger,
    Integer,
    Boolean,
    DateTime,
    ForeignKey,
    JSON,
)
from sqlalchemy.orm import relationship
from src.core.database import Base

def generate_uuid() -> str:
    return str(uuid.uuid4())

class Tenant(Base):
    __tablename__ = "tenants"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    name = Column(String(255), nullable=False)
    slug = Column(String(100), unique=True, nullable=False)
    subscription_tier = Column(String(50), nullable=False, default="solo_reporter")
    settings = Column(JSON, nullable=False, default=lambda: {"max_audio_minutes": 300, "byok_enabled": True})
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    users = relationship("User", back_populates="tenant", cascade="all, delete-orphan")
    interviews = relationship("Interview", back_populates="tenant", cascade="all, delete-orphan")
    articles = relationship("Article", back_populates="tenant", cascade="all, delete-orphan")

class User(Base):
    __tablename__ = "users"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    tenant_id = Column(String(36), ForeignKey("tenants.id", ondelete="CASCADE"), nullable=False)
    email = Column(String(255), unique=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    full_name = Column(String(255), nullable=False)
    role = Column(String(50), nullable=False, default="senior_reporter")
    preferred_language = Column(String(10), nullable=False, default="ar")
    preferred_theme = Column(String(20), nullable=False, default="system")
    is_active = Column(Boolean, nullable=False, default=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    tenant = relationship("Tenant", back_populates="users")
    interviews = relationship("Interview", back_populates="user")
    api_keys = relationship("UserApiKey", back_populates="user", cascade="all, delete-orphan")

class UserApiKey(Base):
    __tablename__ = "user_api_keys"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    tenant_id = Column(String(36), ForeignKey("tenants.id", ondelete="CASCADE"), nullable=False)
    provider = Column(String(50), nullable=False, default="gemini")
    encrypted_key = Column(Text, nullable=False)
    key_preview = Column(String(20), nullable=False)
    is_active = Column(Boolean, nullable=False, default=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    user = relationship("User", back_populates="api_keys")

class Interview(Base):
    __tablename__ = "interviews"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    tenant_id = Column(String(36), ForeignKey("tenants.id", ondelete="CASCADE"), nullable=False)
    user_id = Column(String(36), ForeignKey("users.id", ondelete="RESTRICT"), nullable=True)
    title = Column(String(500), nullable=False)
    media_url = Column(String(1024), nullable=False)
    media_type = Column(String(100), nullable=False)
    file_size_bytes = Column(BigInteger, nullable=False, default=0)
    duration_seconds = Column(Integer, nullable=True)
    processing_status = Column(String(50), nullable=False, default="uploaded")
    language = Column(String(10), nullable=False, default="ar")
    error_message = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    tenant = relationship("Tenant", back_populates="interviews")
    user = relationship("User", back_populates="interviews")
    transcript = relationship("Transcript", uselist=False, back_populates="interview", cascade="all, delete-orphan")
    articles = relationship("Article", back_populates="interview", cascade="all, delete-orphan")

class Transcript(Base):
    __tablename__ = "transcripts"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    interview_id = Column(String(36), ForeignKey("interviews.id", ondelete="CASCADE"), unique=True, nullable=False)
    raw_text = Column(Text, nullable=False)
    diarized_segments = Column(JSON, nullable=False, default=list)
    word_count = Column(Integer, nullable=False, default=0)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    interview = relationship("Interview", back_populates="transcript")

class Article(Base):
    __tablename__ = "articles"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    interview_id = Column(String(36), ForeignKey("interviews.id", ondelete="CASCADE"), nullable=False)
    tenant_id = Column(String(36), ForeignKey("tenants.id", ondelete="CASCADE"), nullable=False)
    headline = Column(String(500), nullable=False)
    subhead = Column(String(1000), nullable=True)
    byline = Column(String(255), nullable=False)
    dateline = Column(String(255), nullable=False)
    lead_paragraph = Column(Text, nullable=False)
    nut_graph = Column(Text, nullable=False)
    body_markdown = Column(Text, nullable=False)
    body_html = Column(Text, nullable=False)
    key_quotes = Column(JSON, nullable=True, default=list)
    language = Column(String(10), nullable=False, default="ar")
    editorial_style = Column(String(50), nullable=False, default="inverted_pyramid")
    word_count = Column(Integer, nullable=False, default=0)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    interview = relationship("Interview", back_populates="articles")
    tenant = relationship("Tenant", back_populates="articles")
    export_logs = relationship("ExportLog", back_populates="article", cascade="all, delete-orphan")

class ExportLog(Base):
    __tablename__ = "export_logs"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    article_id = Column(String(36), ForeignKey("articles.id", ondelete="CASCADE"), nullable=False)
    user_id = Column(String(36), ForeignKey("users.id", ondelete="RESTRICT"), nullable=True)
    export_type = Column(String(50), nullable=False)
    destination_url = Column(String(1024), nullable=True)
    exported_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    article = relationship("Article", back_populates="export_logs")
