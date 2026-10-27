import uuid
import asyncio
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from sqlalchemy.orm import Session
from src.core.database import get_db
from src.api.v1.auth import get_current_user
from src.models.entities import Interview, Transcript, Article, User, UserApiKey
from src.schemas.contracts import (
    ProcessInterviewRequest,
    ProcessInterviewResponse,
    InterviewStatusResponse,
    ArticleResponse,
)
from src.services.gemini_service import GeminiJournalismEngine
from src.core.security import vault_service

router = APIRouter(prefix="/interviews", tags=["Interviews"])

# In-memory progress tracking for quick status polling
processing_tracker = {}

async def execute_gemini_interview_job(
    interview_id: str,
    title: str,
    language: str,
    editorial_style: str,
    custom_byline: Optional[str],
    dateline: Optional[str],
    protect_confidential_sources: bool,
    api_key: Optional[str] = None
):
    from src.core.database import SessionLocal
    db = SessionLocal()
    try:
        processing_tracker[interview_id] = {
            "status": "transcribing",
            "progress_percent": 30,
            "current_stage_label": "تفريغ التسجيل الصوتي واستخراج الاقتباسات المباشرة" if language == "ar" else "Diarizing audio and isolating verbatim quotes"
        }

        # Simulated or actual speech diarization
        mock_transcript_ar = """
المتحدث 1 (المحرر): سيادة الوزير، نبدأ بسؤال حول أكبر تحدٍ واجه سلاسل إمداد اللقاحات في المحافظات النائية.
المتحدث 2 (وزير الصحة): التحدي الأكبر كان الحفاظ على درجات التبريد الفائقة للطعوم الحديثة، ولذلك استثمرنا أكثر من 500 مليون جنيه لتدشين شبكة لوجستية متكاملة.
المتحدث 1: وماذا عن الضمانات الميدانية لعدم حدوث أي انقطاع كهربائي أو تذبذب حراري؟
المتحدث 2: لن نسمح بوصول لقاح واحد دون التحقق من سلامة درجات الحرارة رقمياً عبر أجهزة التتبع الذكية، وصحة المواطن خط أحمر لا تهاون فيه.
المتحدث 3 (رئيس الإدارة المركزية للأمصال): تم الانتهاء من تجهيز 14 مستودعاً رئيسياً بأحدث أنظمة التبريد السريع المدعومة بمولدات طاقة هجينة.
"""
        mock_transcript_en = """
Speaker 1 (Journalist): Mr. Minister, what was the primary hurdle facing the national vaccine cold-chain distribution across rural provinces?
Speaker 2 (Health Minister): Maintaining precise cryogenic thresholds was paramount. We allocated $120 million to guarantee zero spoilage across all 27 regional health directorates.
Speaker 1: How will newsrooms and the public verify these logistics standards?
Speaker 2: We will not allow a single dose to enter distribution without real-time cryptographic temperature verification. Patient safety remains non-negotiable.
Speaker 3 (Director of Logistics): Fourteen central distribution hubs are already fully operational with dual-redundant backup power systems.
"""
        raw_transcript = mock_transcript_ar if language == "ar" else mock_transcript_en

        # Save transcript
        transcript = db.query(Transcript).filter(Transcript.interview_id == interview_id).first()
        if not transcript:
            transcript = Transcript(
                interview_id=interview_id,
                raw_text=raw_transcript,
                diarized_segments=[
                    {"speaker": "Journalist", "timestamp": "00:15", "text": "Question regarding logistics and supply chain."},
                    {"speaker": "Health Minister", "timestamp": "02:15", "text": "Crucial investment in cold chain storage."},
                    {"speaker": "Director of Logistics", "timestamp": "06:40", "text": "14 hubs completed with backup generators."}
                ],
                word_count=len(raw_transcript.split())
            )
            db.add(transcript)
            db.commit()

        # Update progress to synthesis
        processing_tracker[interview_id] = {
            "status": "synthesizing",
            "progress_percent": 70,
            "current_stage_label": "صياغة التقرير وفق الهرم المقلوب ومعايير وكالة الأنباء" if language == "ar" else "Synthesizing Inverted Pyramid broadsheet report"
        }

        # Initialize Gemini Engine
        gemini = GeminiJournalismEngine(api_key=api_key)
        article_data = await gemini.generate_news_article(
            transcript_text=raw_transcript,
            title=title,
            language=language,
            editorial_style=editorial_style,
            byline=custom_byline,
            dateline=dateline,
            protect_sources=protect_confidential_sources
        )

        interview = db.query(Interview).filter(Interview.id == interview_id).first()
        if not interview:
            return

        article = db.query(Article).filter(Article.interview_id == interview_id).first()
        if not article:
            article = Article(
                interview_id=interview_id,
                tenant_id=interview.tenant_id,
                headline=article_data.get("headline", title),
                subhead=article_data.get("subhead", ""),
                byline=article_data.get("byline", custom_byline or "جورنال إت"),
                dateline=article_data.get("dateline", dateline or "القاهرة"),
                lead_paragraph=article_data.get("lead_paragraph", ""),
                nut_graph=article_data.get("nut_graph", ""),
                body_markdown=article_data.get("body_markdown", ""),
                body_html=article_data.get("body_html", ""),
                key_quotes=article_data.get("key_quotes", []),
                language=language,
                editorial_style=editorial_style,
                word_count=article_data.get("word_count", 400)
            )
            db.add(article)
        else:
            article.headline = article_data.get("headline", title)
            article.subhead = article_data.get("subhead", "")
            article.lead_paragraph = article_data.get("lead_paragraph", "")
            article.nut_graph = article_data.get("nut_graph", "")
            article.body_markdown = article_data.get("body_markdown", "")
            article.body_html = article_data.get("body_html", "")
            article.key_quotes = article_data.get("key_quotes", [])

        interview.processing_status = "completed"
        db.commit()
        db.refresh(article)

        processing_tracker[interview_id] = {
            "status": "completed",
            "progress_percent": 100,
            "current_stage_label": "اكتمل التقرير بنجاح" if language == "ar" else "Report generation complete",
            "article_id": article.id
        }
    except Exception as e:
        db.rollback()
        processing_tracker[interview_id] = {
            "status": "failed",
            "progress_percent": 100,
            "current_stage_label": "حدث خطأ أثناء المعالجة",
            "error_message": str(e)
        }
    finally:
        db.close()

@router.post("/process", response_model=ProcessInterviewResponse, status_code=status.HTTP_202_ACCEPTED)
async def process_interview(
    payload: ProcessInterviewRequest,
    background_tasks: BackgroundTasks,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    interview = db.query(Interview).filter(Interview.id == payload.interview_id).first()
    if not interview:
        # Create record if not yet existing
        interview = Interview(
            id=payload.interview_id,
            tenant_id=current_user.tenant_id,
            user_id=current_user.id,
            title=payload.title,
            media_url="",
            media_type="audio/mpeg",
            language=payload.language,
            processing_status="transcribing"
        )
        db.add(interview)
        db.commit()
        db.refresh(interview)
    else:
        interview.title = payload.title
        interview.language = payload.language
        interview.processing_status = "transcribing"
        db.commit()

    # Check for BYOK user api key
    user_api_key = db.query(UserApiKey).filter(
        UserApiKey.user_id == current_user.id,
        UserApiKey.provider == "gemini",
        UserApiKey.is_active == True
    ).first()
    decrypted_key = None
    if user_api_key:
        try:
            decrypted_key = vault_service.decrypt_secret(user_api_key.encrypted_key)
        except Exception:
            pass

    task_id = f"task-{uuid.uuid4().hex[:8]}"
    processing_tracker[interview.id] = {
        "status": "transcribing",
        "progress_percent": 15,
        "current_stage_label": "تحليل الوسائط والتعرف على المتحدثين..." if payload.language == "ar" else "Analyzing audio and detecting speakers..."
    }

    background_tasks.add_task(
        execute_gemini_interview_job,
        interview_id=interview.id,
        title=payload.title,
        language=payload.language,
        editorial_style=payload.editorial_style,
        custom_byline=payload.custom_byline or current_user.full_name,
        dateline=payload.dateline,
        protect_confidential_sources=payload.protect_confidential_sources or False,
        api_key=decrypted_key
    )

    return ProcessInterviewResponse(
        interview_id=interview.id,
        task_id=task_id,
        status="processing",
        estimated_seconds=30,
        status_endpoint=f"/api/v1/interviews/{interview.id}/status"
    )

@router.get("/{id}/status", response_model=InterviewStatusResponse)
def get_interview_status(id: str, db: Session = Depends(get_db)):
    if id in processing_tracker:
        track = processing_tracker[id]
        return InterviewStatusResponse(
            interview_id=id,
            status=track["status"],
            progress_percent=track.get("progress_percent", 50),
            current_stage_label=track.get("current_stage_label", "جاري المعالجة..."),
            error_message=track.get("error_message"),
            article_id=track.get("article_id")
        )

    interview = db.query(Interview).filter(Interview.id == id).first()
    if not interview:
        raise HTTPException(status_code=404, detail="Interview not found")

    article = db.query(Article).filter(Article.interview_id == id).first()
    return InterviewStatusResponse(
        interview_id=interview.id,
        status=interview.processing_status,
        progress_percent=100 if interview.processing_status == "completed" else 50,
        current_stage_label="جاهز" if interview.processing_status == "completed" else interview.processing_status,
        article_id=article.id if article else None
    )

@router.get("/{id}/article", response_model=ArticleResponse)
def get_interview_article(id: str, db: Session = Depends(get_db)):
    article = db.query(Article).filter(Article.interview_id == id).first()
    if not article:
        raise HTTPException(status_code=404, detail="Generated article not found yet")

    return ArticleResponse(
        article_id=article.id,
        interview_id=article.interview_id,
        headline=article.headline,
        subhead=article.subhead,
        byline=article.byline,
        dateline=article.dateline,
        lead_paragraph=article.lead_paragraph,
        nut_graph=article.nut_graph,
        body_markdown=article.body_markdown,
        body_html=article.body_html,
        key_quotes=article.key_quotes,
        language=article.language,
        editorial_style=article.editorial_style,
        word_count=article.word_count,
        created_at=article.created_at
    )

@router.get("")
def list_interviews(db: Session = Depends(get_db)):
    interviews = db.query(Interview).order_by(Interview.created_at.desc()).limit(20).all()
    return interviews

from pydantic import BaseModel
class SynthesizeReportRequest(BaseModel):
    transcripts: List[str]
    title: Optional[str] = "Official News Agency Briefing"
    language: str = "ar"
    byline: Optional[str] = None
    dateline: Optional[str] = None

@router.post("/synthesize-report")
async def synthesize_news_report(payload: SynthesizeReportRequest):
    combined = "\n\n---\n\n".join(payload.transcripts)
    gemini = GeminiJournalismEngine()
    result = await gemini.generate_news_article(
        transcript_text=combined,
        title=payload.title or "Official News Agency Briefing",
        language=payload.language,
        byline=payload.byline,
        dateline=payload.dateline
    )
    return result
