# RESTful API Specification (OpenAPI 3.1)

---

## 1. OpenAPI Route Map

```
POST /api/v1/auth/login                  -> User authentication & HttpOnly cookie emission
POST /api/v1/auth/logout                 -> Clear session cookies & revoke token
GET  /api/v1/users/me                    -> Get current user profile, language & theme preferences
PATCH /api/v1/users/me/preferences       -> Update user UI preferences (language: 'ar'|'en', theme: 'light'|'dark'|'system')

POST /api/v1/media/presign               -> Generate S3 presigned URL for direct media upload
POST /api/v1/media/share-target          -> Ingestion handler for WhatsApp/PWA share target

POST /api/v1/interviews/process          -> Start Gemini transcription & news report pipeline
GET  /api/v1/interviews/{id}/status      -> Long-polling / SSE task progress status
GET  /api/v1/interviews/{id}/article     -> Retrieve generated newspaper article & transcript

POST /api/v1/articles/{id}/export/docx   -> Generate and download formatted Word (.docx) file
POST /api/v1/articles/{id}/export/gdocs  -> Create Google Doc in user's Drive and return URL
POST /api/v1/articles/{id}/track-share   -> Record export analytics (Clipboard, WhatsApp share)

POST /api/v1/settings/gemini-key         -> Store or update encrypted personal Gemini API Key
GET  /api/v1/settings/gemini-key/status  -> Verify if active Gemini key is configured
```

---

## 2. Detailed Endpoint Definitions

### 1. Media Presigned Upload URL
`POST /api/v1/media/presign`  
Allows mobile webview and desktop browser to upload large audio/video files directly to S3/MinIO without blocking the Python API server.

**Request Body:**
```json
{
  "filename": "interview_minister_health.mp4",
  "content_type": "video/mp4",
  "file_size_bytes": 145020110
}
```

**Response (200 OK):**
```json
{
  "interview_id": "018f3a21-9e2c-7b2a-89a1-432d6c123456",
  "upload_url": "https://s3.msoms.ai/journalit-media/raw/018f3a21-9e2c-7b2a-89a1-432d6c123456.mp4?X-Amz-Signature=...",
  "media_url": "https://s3.msoms.ai/journalit-media/raw/018f3a21-9e2c-7b2a-89a1-432d6c123456.mp4",
  "expires_in_seconds": 3600
}
```

---

### 2. Process Interview Recording
`POST /api/v1/interviews/process`  
Enqueues background Celery job to upload media to Gemini File API, transcribe, and draft the news article.

**Request Body:**
```json
{
  "interview_id": "018f3a21-9e2c-7b2a-89a1-432d6c123456",
  "title": "Interview with Health Minister on New Vaccine Logistics",
  "language": "ar",
  "editorial_style": "inverted_pyramid",
  "custom_byline": "أحمد محمود — صحفي تحقيقات",
  "dateline": "القاهرة"
}
```

**Response (202 Accepted):**
```json
{
  "interview_id": "018f3a21-9e2c-7b2a-89a1-432d6c123456",
  "task_id": "celery-task-8899aabb-1122",
  "status": "processing",
  "estimated_seconds": 45,
  "status_endpoint": "/api/v1/interviews/018f3a21-9e2c-7b2a-89a1-432d6c123456/status"
}
```

---

### 3. Retrieve Generated Article
`GET /api/v1/interviews/{id}/article`

**Response (200 OK):**
```json
{
  "article_id": "99887766-5544-3322-1100-aabbccddeeff",
  "interview_id": "018f3a21-9e2c-7b2a-89a1-432d6c123456",
  "headline": "وزير الصحة يعلن تدشين أكبر شبكة تبريد لتوزيع اللقاحات في الشرق الأوسط",
  "subhead": "الخطة تشمل تغطية 27 محافظة بحلول نهاية العام الجاري باستثمارات تتجاوز 500 مليون جنيه",
  "byline": "أحمد محمود — صحفي تحقيقات",
  "dateline": "القاهرة — جورنال إت",
  "lead_paragraph": "أعلن وزير الصحة والسكان اليوم عن إطلاق المرحلة الأولى من المنظومة اللوجستية المتطورة لحفظ وتوزيع الطعوم والأمصال، مؤكداً وصول الدفعة الأولى من وحدات التبريد العملاقة للمستودعات المركزية.",
  "nut_graph": "وتأتي هذه التحركات وسط مساعٍ حكومية مكثفة لرفع كفاءة سلاسل الإمداد الطبي وتقليص الفاقد من اللقاحات إلى أقل من 1%، مما يعزز الأمن الدوائي للمواطنين.",
  "body_markdown": "### تفاصيل اللقاء الاستقصائي\n\nأوضح الوزير في حديث خاص ومسجل أن المشروع لا يقتصر فقط على التبريد...",
  "key_quotes": [
    {
      "speaker": "وزير الصحة",
      "timestamp": "04:15",
      "quote": "لن نسمح بوصول لقاح واحد دون التحقق من سلامة درجات الحرارة رقمياً عبر أجهزة التتبع الذكية."
    }
  ],
  "language": "ar",
  "word_count": 520,
  "created_at": "2026-10-22T20:15:00Z"
}
```

---

### 4. Export to Microsoft Word (.docx)
`POST /api/v1/articles/{id}/export/docx`

**Response:** Binary Stream (`application/vnd.openxmlformats-officedocument.wordprocessingml.document`) with Header:  
`Content-Disposition: attachment; filename="JournalIt_Report_Health_Minister.docx"`

---

### 5. Export to Google Docs
`POST /api/v1/articles/{id}/export/gdocs`

**Response (200 OK):**
```json
{
  "google_doc_id": "1A2B3C4D5E6F7G8H9I0J",
  "google_doc_url": "https://docs.google.com/document/d/1A2B3C4D5E6F7G8H9I0J/edit",
  "title": "تقرير صحفي: وزير الصحة يعلن تدشين أكبر شبكة تبريد"
}
```

---

### 6. Update User Preferences (Language & Theme)
  
Persists senior journalist interface settings (bilingual language choice and dark/light theme switch).

**Request Body:**
```json
{
  "preferred_language": "ar",
  "preferred_theme": "dark"
}
```

**Response (200 OK):**
```json
{
  "user_id": "018f3a21-9e2c-7b2a-89a1-654d6c987654",
  "preferred_language": "ar",
  "preferred_theme": "dark",
  "updated_at": "2026-10-22T20:30:00Z"
}
```
