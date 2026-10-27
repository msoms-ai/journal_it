from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from src.core.database import get_db
from src.core.security import vault_service
from src.api.v1.auth import get_current_user
from src.models.entities import User, UserApiKey
from src.schemas.contracts import GeminiKeyUpdateRequest, GeminiKeyStatusResponse

router = APIRouter(prefix="/settings", tags=["Settings"])

@router.post("/gemini-key", response_model=GeminiKeyStatusResponse)
def update_gemini_key(
    payload: GeminiKeyUpdateRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    key = payload.api_key.strip()
    encrypted = vault_service.encrypt_secret(key)
    preview = f"{key[:6]}...{key[-4:]}" if len(key) >= 10 else "***"

    user_key = db.query(UserApiKey).filter(
        UserApiKey.user_id == current_user.id,
        UserApiKey.provider == "gemini"
    ).first()

    if user_key:
        user_key.encrypted_key = encrypted
        user_key.key_preview = preview
        user_key.is_active = True
    else:
        user_key = UserApiKey(
            user_id=current_user.id,
            tenant_id=current_user.tenant_id,
            provider="gemini",
            encrypted_key=encrypted,
            key_preview=preview,
            is_active=True
        )
        db.add(user_key)

    db.commit()

    return GeminiKeyStatusResponse(
        is_configured=True,
        provider="gemini",
        key_preview=preview
    )

@router.get("/gemini-key/status", response_model=GeminiKeyStatusResponse)
def get_gemini_key_status(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    user_key = db.query(UserApiKey).filter(
        UserApiKey.user_id == current_user.id,
        UserApiKey.provider == "gemini",
        UserApiKey.is_active == True
    ).first()

    if user_key:
        return GeminiKeyStatusResponse(
            is_configured=True,
            provider="gemini",
            key_preview=user_key.key_preview
        )

    # Check if system-wide key exists
    from src.core.config import settings
    has_system_key = bool(settings.GEMINI_API_KEY and len(settings.GEMINI_API_KEY) > 10)

    return GeminiKeyStatusResponse(
        is_configured=has_system_key,
        provider="gemini",
        key_preview="AIzaSy...System" if has_system_key else None
    )
