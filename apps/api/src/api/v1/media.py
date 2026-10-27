import os
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form, status
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session
from src.core.database import get_db
from src.core.config import settings
from src.api.v1.auth import get_current_user
from src.models.entities import Interview, User, Tenant
from src.schemas.contracts import PresignUploadRequest, PresignUploadResponse
from src.services.storage_service import storage_service
from src.services.gemini_service import gemini_engine

router = APIRouter(prefix="/media", tags=["Media"])

@router.post("/transcribe")
async def transcribe_uploaded_media(
    file: UploadFile = File(...),
    language: str = Form("ar")
):
    """
    Directly transcribes an uploaded audio or video file using Gemini 3.8 Flash.
    """
    try:
        content = await file.read()
        if not content or len(content) == 0:
            raise HTTPException(status_code=400, detail="Empty file uploaded")

        filename = file.filename or "recording.mp3"
        mime_type = file.content_type or "audio/mpeg"

        transcript = await gemini_engine.transcribe_media_file(
            file_bytes=content,
            filename=filename,
            mime_type=mime_type,
            language=language
        )

        return {
            "status": "completed",
            "filename": filename,
            "transcript": transcript
        }
    except Exception as e:
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/presign", response_model=PresignUploadResponse)
def presign_upload(
    payload: PresignUploadRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    interview = Interview(
        tenant_id=current_user.tenant_id,
        user_id=current_user.id,
        title=os.path.splitext(payload.filename)[0],
        media_url="",
        media_type=payload.content_type,
        file_size_bytes=payload.file_size_bytes,
        processing_status="uploaded",
        language=current_user.preferred_language
    )
    db.add(interview)
    db.commit()
    db.refresh(interview)

    upload_url, media_url = storage_service.generate_presigned_upload(
        interview_id=interview.id,
        filename=payload.filename,
        content_type=payload.content_type
    )

    interview.media_url = media_url
    db.commit()

    return PresignUploadResponse(
        interview_id=interview.id,
        upload_url=upload_url,
        media_url=media_url,
        expires_in_seconds=3600
    )

@router.post("/upload")
async def direct_upload(
    interview_id: str,
    filename: str,
    file: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    content = await file.read()
    storage_service.save_file(filename, content)

    interview = db.query(Interview).filter(Interview.id == interview_id).first()
    if interview:
        interview.file_size_bytes = len(content)
        interview.processing_status = "uploaded"
        db.commit()

    return {"status": "success", "filename": filename, "size_bytes": len(content)}

@router.get("/files/{filename}")
def serve_file(filename: str):
    file_path = storage_service.get_file_path(filename)
    if not file_path.exists():
        raise HTTPException(status_code=404, detail="File not found")
    return FileResponse(file_path)
