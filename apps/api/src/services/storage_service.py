import os
import shutil
from pathlib import Path
from typing import Tuple
from src.core.config import settings

class StorageService:
    def __init__(self):
        self.upload_dir = Path(settings.STORAGE_LOCAL_DIR)
        self.upload_dir.mkdir(parents=True, exist_ok=True)

    def generate_presigned_upload(self, interview_id: str, filename: str, content_type: str) -> Tuple[str, str]:
        ext = os.path.splitext(filename)[1] or ".mp3"
        safe_filename = f"{interview_id}{ext}"
        
        # Local upload URL handled by FastAPI media upload endpoint
        upload_url = f"{settings.API_BASE_URL}/api/v1/media/upload?interview_id={interview_id}&filename={safe_filename}"
        media_url = f"{settings.API_BASE_URL}/api/v1/media/files/{safe_filename}"
        return upload_url, media_url

    def save_file(self, filename: str, file_bytes: bytes) -> str:
        filepath = self.upload_dir / filename
        with open(filepath, "wb") as f:
            f.write(file_bytes)
        return str(filepath)

    def get_file_path(self, filename: str) -> Path:
        return self.upload_dir / filename

storage_service = StorageService()
