from typing import Optional
from pydantic import BaseModel
from fastapi import APIRouter, Depends, HTTPException, Response, status
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session
from src.core.database import get_db
from src.api.v1.auth import get_current_user
from src.models.entities import Article, ExportLog, User
from src.schemas.contracts import ArticleResponse, TrackShareRequest, GoogleDocsExportResponse
from src.services.docx_service import DocxBroadsheetService
from src.services.gdocs_service import gdocs_service

router = APIRouter(prefix="/articles", tags=["Articles"])

class DirectExportDocxRequest(BaseModel):
    report_text: Optional[str] = ""
    body_markdown: Optional[str] = ""
    language: Optional[str] = "ar"
    title: Optional[str] = ""

@router.post("/export-docx")
def export_direct_docx(payload: DirectExportDocxRequest):
    """Direct export endpoint without requiring database persistence or auth."""
    article_dict = {
        "report_text": payload.report_text or payload.body_markdown or "",
        "body_markdown": payload.body_markdown or payload.report_text or "",
        "language": payload.language or "ar",
    }
    docx_stream = DocxBroadsheetService.generate_article_docx(article_dict)
    filename = "Sahhif_News_Report.docx" if payload.language == "ar" else "Journal_It_Report.docx"
    return StreamingResponse(
        docx_stream,
        media_type="application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        headers={
            "Content-Disposition": f'attachment; filename="{filename}"',
            "Access-Control-Expose-Headers": "Content-Disposition"
        }
    )

@router.get("/{id}", response_model=ArticleResponse)
def get_article(id: str, db: Session = Depends(get_db)):
    article = db.query(Article).filter(Article.id == id).first()
    if not article:
        raise HTTPException(status_code=404, detail="Article not found")

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

@router.post("/{id}/export/docx")
def export_docx(
    id: str,
    db: Session = Depends(get_db)
):
    article = db.query(Article).filter(Article.id == id).first()
    if not article:
        # Fallback graceful handler for synthesized in-memory reports
        article_dict = {
            "report_text": "تقرير إخباري معتمد",
            "body_markdown": "تقرير إخباري معتمد",
            "language": "ar"
        }
    else:
        article_dict = {
            "headline": article.headline,
            "subhead": article.subhead,
            "byline": article.byline,
            "dateline": article.dateline,
            "lead_paragraph": article.lead_paragraph,
            "nut_graph": article.nut_graph,
            "body_markdown": article.body_markdown,
            "body_html": article.body_html,
            "key_quotes": article.key_quotes or [],
            "language": article.language,
        }

    docx_stream = DocxBroadsheetService.generate_article_docx(article_dict)

    if article:
        try:
            log = ExportLog(
                article_id=article.id,
                user_id=None,
                export_type="docx"
            )
            db.add(log)
            db.commit()
        except Exception:
            db.rollback()

    filename = f"JournalIt_Report_{article.id[:8]}.docx"
    headers = {
        "Content-Disposition": f'attachment; filename="{filename}"'
    }
    return StreamingResponse(
        docx_stream,
        media_type="application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        headers=headers
    )

@router.post("/{id}/export/gdocs", response_model=GoogleDocsExportResponse)
async def export_gdocs(
    id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    article = db.query(Article).filter(Article.id == id).first()
    if not article:
        raise HTTPException(status_code=404, detail="Article not found")

    article_dict = {
        "headline": article.headline,
        "subhead": article.subhead,
        "byline": article.byline,
        "dateline": article.dateline,
        "lead_paragraph": article.lead_paragraph,
        "nut_graph": article.nut_graph,
        "body_markdown": article.body_markdown,
        "body_html": article.body_html,
        "key_quotes": article.key_quotes or [],
        "language": article.language,
    }

    gdocs_res = await gdocs_service.export_to_google_docs(article_dict)

    log = ExportLog(
        article_id=article.id,
        user_id=current_user.id if current_user else None,
        export_type="google_docs",
        destination_url=gdocs_res["google_doc_url"]
    )
    db.add(log)
    db.commit()

    return GoogleDocsExportResponse(
        google_doc_id=gdocs_res["google_doc_id"],
        google_doc_url=gdocs_res["google_doc_url"],
        title=gdocs_res["title"]
    )

@router.post("/{id}/track-share")
def track_share(
    id: str,
    payload: TrackShareRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    article = db.query(Article).filter(Article.id == id).first()
    if not article:
        raise HTTPException(status_code=404, detail="Article not found")

    log = ExportLog(
        article_id=article.id,
        user_id=current_user.id if current_user else None,
        export_type=payload.export_type,
        destination_url=payload.destination_url
    )
    db.add(log)
    db.commit()

    return {"status": "tracked", "export_type": payload.export_type}
