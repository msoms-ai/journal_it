from fastapi.testclient import TestClient
from src.main import app

client = TestClient(app)

def test_healthcheck():
    response = client.get("/api/v1/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"

def test_root_info():
    response = client.get("/")
    assert response.status_code == 200
    assert "Journal it" in response.json()["name"]

def test_media_presign():
    payload = {
        "filename": "minister_press_briefing.m4a",
        "content_type": "audio/m4a",
        "file_size_bytes": 5242880
    }
    response = client.post("/api/v1/media/presign", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert "interview_id" in data
    assert "upload_url" in data
