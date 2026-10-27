from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from src.core.database import get_db
from src.api.v1.auth import get_current_user
from src.models.entities import User
from src.schemas.contracts import UserProfileResponse, UserPreferencesUpdate

router = APIRouter(prefix="/users", tags=["Users"])

@router.get("/me", response_model=UserProfileResponse)
def get_user_profile(current_user: User = Depends(get_current_user)):
    return current_user

@router.patch("/me/preferences")
def update_user_preferences(
    preferences: UserPreferencesUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    if preferences.preferred_language:
        current_user.preferred_language = preferences.preferred_language
    if preferences.preferred_theme:
        current_user.preferred_theme = preferences.preferred_theme
    db.commit()
    db.refresh(current_user)

    return {
        "user_id": current_user.id,
        "preferred_language": current_user.preferred_language,
        "preferred_theme": current_user.preferred_theme,
        "updated_at": current_user.updated_at
    }
