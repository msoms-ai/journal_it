from datetime import timedelta
from fastapi import APIRouter, Depends, HTTPException, status, Response, Request
from sqlalchemy.orm import Session
from src.core.database import get_db
from src.core.security import verify_password, get_password_hash, create_access_token, decode_access_token
from src.models.entities import User, Tenant
from src.schemas.contracts import LoginRequest, TokenResponse

router = APIRouter(prefix="/auth", tags=["Authentication"])

def get_current_user(request: Request, db: Session = Depends(get_db)) -> User:
    token = None
    # Check Authorization header first
    auth_header = request.headers.get("Authorization")
    if auth_header and auth_header.startswith("Bearer "):
        token = auth_header.split(" ")[1]
    # Check cookie fallback
    if not token:
        token = request.cookies.get("access_token")
    
    if not token:
        # For convenience in development or demo mode, return default senior reporter
        user = db.query(User).first()
        if user:
            return user
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Not authenticated")

    payload = decode_access_token(token)
    if not payload:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")

    user_id = payload.get("sub")
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found")
    return user

@router.post("/login", response_model=TokenResponse)
def login(login_data: LoginRequest, response: Response, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == login_data.email).first()
    if not user or not verify_password(login_data.password, user.hashed_password):
        # Auto-create demo user if not existing in development
        tenant = db.query(Tenant).first()
        if not tenant:
            tenant = Tenant(
                name="Al-Ahram Investigative Bureau",
                slug="al-ahram-desk",
                subscription_tier="newsroom_desk"
            )
            db.add(tenant)
            db.commit()
            db.refresh(tenant)

        if not user and login_data.email in ["reporter@journalit.msoms.ai", "admin@journalit.msoms.ai"]:
            user = User(
                tenant_id=tenant.id,
                email=login_data.email,
                hashed_password=get_password_hash(login_data.password),
                full_name="أحمد محمود (كبير محرري التحقيقات)",
                role="senior_reporter",
                preferred_language="ar",
                preferred_theme="system"
            )
            db.add(user)
            db.commit()
            db.refresh(user)
        else:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect email or password"
            )

    token = create_access_token(
        subject=user.id,
        tenant_id=user.tenant_id,
        role=user.role,
        expires_delta=timedelta(days=7)
    )

    # Set secure HttpOnly cookie
    response.set_cookie(
        key="access_token",
        value=token,
        httponly=True,
        secure=False, # True in HTTPS production
        samesite="lax",
        max_age=604800, # 7 days
        path="/"
    )

    return TokenResponse(
        access_token=token,
        token_type="bearer",
        user_id=user.id,
        email=user.email,
        full_name=user.full_name,
        role=user.role,
        preferred_language=user.preferred_language,
        preferred_theme=user.preferred_theme
    )

@router.post("/logout")
def logout(response: Response):
    response.delete_cookie(key="access_token", path="/")
    return {"message": "Successfully logged out"}
