# صَحِّف | Journal it

<div align="center">

![صَحِّف — Journal it Logo](apps/web/public/assets/journal_it_logo.jpg)

**منصة التحرير الإخباري الذكية لتحويل المقابلات الصوتية والمرئية إلى تقارير صحفية معتمدة**  
**Smart Editorial Application Converting Interview Audio & Video Snippets into Authoritative News Reports**

[![Platform Version](https://img.shields.io/badge/Platform%20Version-1.0.0-crimson.svg)](#)
[![AI Engine](https://img.shields.io/badge/AI%20Model-Gemini%203.8%20Flash-blue.svg)](#)
[![Initiative](https://img.shields.io/badge/Initiative-msoms.ai%202026-darkgreen.svg)](https://msoms.ai)
[![License](https://img.shields.io/badge/License-GPL%203.0-blue.svg)](LICENSE)

</div>

---

## Language Navigation / التنقل السريع بين اللغات
- [English Documentation](#english-documentation)
- [التوثيق باللغة العربية](#التوثيق-باللغة-العربية)

---

<a name="english-documentation"></a>
## English Documentation

### 1. Overview
**صَحِّف (Journal it)** is an AI-powered editorial platform developed as an initiative by **msoms.ai** (2026). It is designed for newsrooms, media agencies, journalists, and government communication teams to streamline the ingestion of raw interview recordings (audio and video) and transform them into concise, authoritative, one-shot journalistic reports composed purely of cohesive narrative paragraphs based on sources.

The platform eliminates the technical overhead of transcription and news writing by orchestrating Google's latest multimodal **Gemini 3.8 Flash** engine through a clean, distraction-free web interface rendered in the unified **Dubai Font**.

---

### 2. Core Capabilities & Architectural Workflow

#### 1. Unified Multi-Format File Ingestion
- Upload multiple audio and video snippets in a single batch (`.mp3`, `.wav`, `.m4a`, `.mp4`, `.mov`, `.webm`).
- Real-time file inventory displaying file format, file size, readiness status, and individual item deletion.

#### 2. Multimodal AI Transcription & Real-Time Progress
- High-fidelity verbatim transcription using Google Gemini 3.8 Flash (inline base64 for files up to 15MB, resumable Gemini Files API for large media).
- Real-time animated progress bar (0%–100%) keeping journalists informed of active file processing.
- **Speaker Recognition & Name Extraction:** Prompts enforce capturing and labeling speakers with their real full names, official titles, and affiliations whenever introduced or addressed in the audio.

#### 3. Interactive Transcripts Review
- Clean card-based review screen for each transcribed file.
- Individual file actions: **Copy Text** to clipboard and **Retranscribe** single files on demand.
- Selective synthesis: Select specific recordings or use the **"Select All"** master toggle to choose which transcripts feed into the news report.

#### 4. Plain One-Shot News Report Synthesis
- Converts transcripts into a structured, flowing broadsheet narrative organized by sources.
- **Strictly No Titles or Subtitles:** Removes headlines, subheads (decks), and markdown headers (`###`) to produce a continuous, high-impact journalistic piece.
- **Explicit Speaker Attribution:** Identifies each speaker by real full name and official title, explaining what they said, what they think, and their strategic assessments.
- **Conversational Filter:** Removes verbal tics, citations, quote snippets, and colloquialisms, transforming statements into polished news wire narrative.

#### 5. Publication & Multi-Format Export
- **Instant Clipboard Copy:** One-click copy of the plain report narrative.
- **Word Document (.docx) Generator:** Generates a publication-ready Word file formatted in the official **Dubai Font** with masthead and flowing paragraphs.
- **Print Preview:** Clean, print-optimized stylesheet.

---

### 3. Tech Stack

| Layer | Technologies |
|---|---|
| **Frontend** | Next.js 14 (App Router), React 18, TypeScript, Tailwind CSS, Lucide Icons |
| **Typography** | Dubai Font Family (`Dubai-Regular`, `Dubai-Medium`, `Dubai-Bold`, `Dubai-Light`) |
| **Backend API** | FastAPI, Python 3.14, Uvicorn, Pydantic v2, SQLAlchemy, HTTPX |
| **Document Engine** | `python-docx` (Custom Broadsheet Formatter) |
| **AI Intelligence** | Google Gemini 3.8 Flash Multimodal API (Direct REST Integration) |

---

### 4. Repository Structure

```text
journal_it/
├── Fonts/                         # Dubai Font Family (.ttf files)
├── apps/
│   ├── web/                       # Next.js 14 Frontend Application
│   │   ├── public/
│   │   │   ├── assets/            # Platform Logo & Branding assets
│   │   │   └── fonts/             # Web Dubai Font assets
│   │   ├── src/
│   │   │   ├── app/               # Root Layout and Main Editorial Flow Page
│   │   │   ├── components/        # Header, Footer, and UI Components
│   │   │   ├── lib/               # API Clients, Types & Bilingual Dictionaries
│   │   │   └── styles/            # Tailwind Global Styles & Font Face definitions
│   │   └── package.json
│   ├── api/                       # FastAPI Backend Application
│   │   ├── src/
│   │   │   ├── api/v1/            # REST Endpoints (articles, media, interviews)
│   │   │   ├── core/              # Config, Database and Security modules
│   │   │   ├── models/            # SQLAlchemy database entities
│   │   │   ├── schemas/           # Pydantic request and response schemas
│   │   │   └── services/          # Gemini AI Engine & Word (.docx) Service
│   │   └── tests/                 # PyTest automated test suite
│   └── mobile_flutter/            # Flutter mobile application
├── docker/                        # Dockerfile and Docker Compose configurations
├── .env.example                   # Environment variable template
├── .gitignore                     # Git ignore rules
└── README.md                      # Comprehensive bilingual documentation
```

---

### 5. Getting Started & Setup Guide

#### Prerequisites
- **Node.js**: v18.17+ or v20+
- **Python**: v3.11+ (Fully tested on Python 3.14)
- **Google Gemini API Key**: [Google AI Studio](https://aistudio.google.com/)

#### Step 1: Clone Repository
```bash
git clone https://github.com/msoms-ai/journal_it.git
cd journal_it
```

#### Step 2: Configure Environment Variables
Copy the `.env.example` file to `.env`:
```bash
cp .env.example .env
```
Ensure your Gemini API key is provided:
```env
GEMINI_API_KEY=your_gemini_api_key_here
GEMINI_MODEL_DEFAULT=gemini-3.8-flash
```

#### Step 3: Run FastAPI Backend
```bash
# Set Python path and start API server
$env:PYTHONPATH="apps/api"   # Windows PowerShell
# or for Linux/macOS: export PYTHONPATH="apps/api"

python -m uvicorn src.main:app --port 8000 --host 127.0.0.1 --reload
```
API Health Check: `http://127.0.0.1:8000/api/v1/health`  
Interactive Swagger Docs: `http://127.0.0.1:8000/docs`

#### Step 4: Run Next.js Frontend
```bash
cd apps/web
npm install
npm run build
npm start
```
Frontend Web Portal: `http://localhost:3000`

---

### 6. API Endpoints Reference

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/v1/media/transcribe` | Transcribes audio/video file with speaker identification using Gemini 3.8 Flash |
| `POST` | `/api/v1/interviews/synthesize-report` | Synthesizes selected transcripts into a one-shot narrative report |
| `POST` | `/api/v1/articles/export-docx` | Generates and streams a formatted Word (.docx) document |
| `GET` | `/api/v1/health` | Service health status check |

---

<br />
<hr />
<br />

<a name="التوثيق-باللغة-العربية"></a>
## التوثيق باللغة العربية

### 1. نظرة عامة
**صَحِّف (Journal it)** هي منصة ذكاء اصطناعي تحريرية متقدمة أُطلقت ضمن مبادرات **msoms.ai** لعام 2026. تهدف المنصة إلى تمكين غرف الأخبار، ووكالات الأنباء، والصحفيين، وفرق الإعلام الحكومي والمؤسسي من تحويل التسجيلات الصوتية والمرئية للمقابلات والمؤتمرات الصحفية إلى **تقارير إخبارية مباشرة مؤلفة من فقرات صحفية متصلة** ومبنية على المصادر وفق أعلى معايير الصياغة المعتمدة.

تتجاوز المنصة تعقيدات التفريغ اليدوي والصياغة التقليدية من خلال دمج مباشر مع أحدث محركات الذكاء الاصطناعي متعددة الوسائط **Gemini 3.8 Flash**، مع واجهة مستخدم عربية أنيقة وسهلة تعتمد **خط دبي (Dubai Font)** الرسمي.

---

### 2. أبرز المميزات وسير العمل التحريري

#### 1. رفع متعدد وشامل للملفات
- إمكانية رفع مقاطع صوتية وفيديو متعددة دفعة واحدة عبر زر رفع مركزي يدعم الامتدادات (`.mp3`, `.wav`, `.m4a`, `.mp4`, `.mov`, `.webm`).
- جدول تفاعلي منظم يعرض تفاصيل الملفات المرفوعة وحجمها وحالتها التشغيلية مع إمكانية حذف أي ملف بضغطة زر.

#### 2. تفريغ صوتي فائق الدقة مع شريط تقدم مباشر
- تفريغ دقيق للكلام المنطوق باللغة الأصلية باستخدام محرك Gemini 3.8 Flash.
- شريط تقدم تفاعلي لحظي (0% - 100%) يُظهر للمحرر حالة المعالجة ومتابعة الملف النشط.
- **التعرف الصريح على المتحدثين:** توجيه صارم للذكاء الاصطناعي لاستخراج الأسماء الحقيقية والصفات والألقاب الرسمية لكل شخص يتحدث في المقابلة أو يُعرّف به في التسجيل، ومنع المسميات المجهولة مثل "المتحدث".

#### 3. مراجعة وتحكم كامل بالتفريغات
- بطاقات منفصلة لكل ملف مفرّغ مع إمكانية **نسخ النص** أو **إعادة التفريغ** لأي تسجيل على حدة.
- مربعات اختيار تفاعلية لتحديد المقابلات المراد تضمينها في التقرير مع زر "تحديد الكل".

#### 4. صياغة تقرير صحفي مباشر بالفقرات (One-Shot)
- صياغة تقرير إخباري يجمع محتوى المصادر المختارة في فقرات متدفقة ورصينة.
- **بدون عناوين أو ترويسات:** إلغاء العناوين الرئيسية والعناوين الفرعية وترويسات الأقسام (`###`) لتقديم نص سردي صحفي موحد ومباشر.
- **نسب التصريحات للمتحدثين بأسمائهم:** ذكر اسم كل متحدث ومنصبه بوضوح وسرد ما صرّح به ورؤيته وتقييمه في سياق صحفي رفيع.
- **تنقية النص من الشوائب الحوارية:** إزالة الحشو اللفظي والاقتباسات المنفصلة وتكلف العبارات الشفهية وتحويلها إلى صياغة صحفية رصينة.

#### 5. خيارات النشر والتصدير المتعددة
- **نسخ فوري للتقرير:** نسخ كامل نص الفقرات بنقرة واحدة إلى الحافظة.
- **تصدير مستند Word (.docx):** توليد ملف وورد معتمد ومنسق بخط دبي، متوافق مع الاتجاه من اليمين لليسار (RTL).
- **طباعة مباشرة:** تنسيق جاهز للطباعة الصحفية الخالية من العناصر غير التحريرية.

---

### 3. البنية التقنية للمنصة

| الطبقة التقنية | التقنيات المستخدمة |
|---|---|
| **واجهة المستخدم (Frontend)** | Next.js 14, React 18, TypeScript, Tailwind CSS, Lucide Icons |
| **الخطوط والطباعة** | عائلة خط دبي الرسمية (`Dubai-Regular`, `Dubai-Medium`, `Dubai-Bold`, `Dubai-Light`) |
| **الواجهة الخلفية (Backend API)** | FastAPI, Python 3.14, Uvicorn, Pydantic v2, SQLAlchemy, HTTPX |
| **محرك تصدير المستندات** | `python-docx` مخصص لنظام الفقرات والترويسة الصحفية |
| **الذكاء الاصطناعي** | Google Gemini 3.8 Flash عبر واجهة برمجية REST مباشرة وفائقة السرعة |

---

### 4. دليل التثبيت والتشغيل المحلي

#### المتطلبات المسبقة
- بيئة عمل **Node.js** (الإصدار 18 أو 20 وما فوق).
- بيئة عمل **Python** (الإصدار 3.11 أو أحدث، تم التحقق والتوافق التام مع Python 3.14).
- مفتاح Google Gemini API صالح.

#### خطوات التشغيل:
```bash
# 1. استنساخ المستودع
git clone https://github.com/msoms-ai/journal_it.git
cd journal_it

# 2. إعداد متغيرات البيئة
cp .env.example .env
# قم بوضع مفتاح الذكاء الاصطناعي داخل ملف .env:
# GEMINI_API_KEY=your_key_here

# 3. تشغيل الواجهة الخلفية (FastAPI)
$env:PYTHONPATH="apps/api"
python -m uvicorn src.main:app --port 8000 --host 127.0.0.1 --reload

# 4. تشغيل الواجهة الأمامية (Next.js)
cd apps/web
npm install
npm run build
npm start
```

- رابط المنصة الرئيسي: `http://localhost:3000`
- فحص حالة الواجهة الخلفية: `http://127.0.0.1:8000/api/v1/health`
- توثيق واجهات API التفاعلية: `http://127.0.0.1:8000/docs`

---

### 5. الحقوق والملكية
- تطوير وإطلاق: **مبادرة الذكاء الاصطناعي من msoms.ai — 2026**
- إصدار المنصة: **Platform Version 1.0.0**
- محرك الذكاء الاصطناعي: **Gemini 3.8 Flash**
