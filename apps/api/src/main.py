import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from src.core.config import settings
from src.core.database import Base, engine, SessionLocal
from src.core.security import get_password_hash
from src.models.entities import Tenant, User
from src.api.v1.auth import router as auth_router
from src.api.v1.users import router as users_router
from src.api.v1.media import router as media_router
from src.api.v1.interviews import router as interviews_router
from src.api.v1.articles import router as articles_router
from src.api.v1.settings import router as settings_router

# Initialize database tables
Base.metadata.create_all(bind=engine)

def seed_initial_data():
    db = SessionLocal()
    try:
        tenant = db.query(Tenant).first()
        if not tenant:
            tenant = Tenant(
                name="Al-Ahram Investigative Bureau",
                slug="al-ahram-desk",
                subscription_tier="newsroom_desk",
                settings={"max_audio_minutes": 1000, "byok_enabled": True}
            )
            db.add(tenant)
            db.commit()
            db.refresh(tenant)

        user = db.query(User).first()
        if not user:
            user = User(
                tenant_id=tenant.id,
                email="reporter@journalit.msoms.ai",
                hashed_password=get_password_hash("journal_secret"),
                full_name="أحمد محمود (كبير محرري التحقيقات)",
                role="senior_reporter",
                preferred_language="ar",
                preferred_theme="system"
            )
            db.add(user)
            db.commit()
    finally:
        db.close()

seed_initial_data()

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="AI-Powered Mobile & Web Investigative Journalism Studio for Voice & Video Interviews - msoms.ai"
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # Allow development frontend origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register routers
app.include_router(auth_router, prefix=settings.API_V1_STR)
app.include_router(users_router, prefix=settings.API_V1_STR)
app.include_router(media_router, prefix=settings.API_V1_STR)
app.include_router(interviews_router, prefix=settings.API_V1_STR)
app.include_router(articles_router, prefix=settings.API_V1_STR)
app.include_router(settings_router, prefix=settings.API_V1_STR)

@app.get("/")
def root():
    return {
        "name": "Journal it (صَحِّف)",
        "version": settings.VERSION,
        "organization": "msoms.ai",
        "docs_url": "/docs",
        "status": "operational"
    }

@app.get("/api/v1/health")
def healthcheck():
    return {"status": "ok", "service": "journal_it_api"}
