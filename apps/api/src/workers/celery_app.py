import os
from celery import Celery
from src.core.config import settings

celery_app = Celery(
    "journal_it_worker",
    broker=os.getenv("REDIS_URL", "redis://localhost:6379/0"),
    backend=os.getenv("REDIS_URL", "redis://localhost:6379/0"),
)

celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="UTC",
    enable_utc=True,
)

@celery_app.task(name="process_audio_interview_task")
def process_audio_interview_task(interview_id: str, language: str, editorial_style: str):
    """
    Celery background worker task for production clustering.
    Calls Gemini Multimodal File API for large audio/video batches.
    """
    import asyncio
    from src.api.v1.interviews import execute_gemini_interview_job
    
    asyncio.run(
        execute_gemini_interview_job(
            interview_id=interview_id,
            title="Interview Batch",
            language=language,
            editorial_style=editorial_style,
            custom_byline=None,
            dateline=None,
            protect_confidential_sources=False
        )
    )
    return {"status": "completed", "interview_id": interview_id}
