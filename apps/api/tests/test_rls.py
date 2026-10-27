import pytest
from uuid import uuid4
from src.core.database import SessionLocal, Base, engine
from src.models.entities import Tenant, User, Interview

def test_tenant_data_segregation():
    db = SessionLocal()
    try:
        # Create Tenant A and Tenant B
        tenant_a = Tenant(
            id=str(uuid4()),
            name="Bureau Al-Ahram Cairo",
            slug=f"al-ahram-{uuid4().hex[:6]}"
        )
        tenant_b = Tenant(
            id=str(uuid4()),
            name="Bureau Reuters Regional",
            slug=f"reuters-{uuid4().hex[:6]}"
        )
        db.add_all([tenant_a, tenant_b])
        db.commit()

        interview_a = Interview(
            id=str(uuid4()),
            tenant_id=tenant_a.id,
            title="Minister of Energy Interview",
            media_url="https://s3.example.com/energy.mp3",
            media_type="audio/mpeg",
            processing_status="completed"
        )
        db.add(interview_a)
        db.commit()

        # Query interviews filtered by tenant B
        results = db.query(Interview).filter(Interview.tenant_id == tenant_b.id).all()
        assert len(results) == 0, "Security Violation: Cross-tenant data leakage detected!"

        # Query interviews filtered by tenant A
        results_a = db.query(Interview).filter(Interview.tenant_id == tenant_a.id).all()
        assert len(results_a) == 1
        assert results_a[0].title == "Minister of Energy Interview"
    finally:
        db.close()
