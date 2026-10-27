# صَحِّف | Journal it

<div align="center">

![صَحِّف — Journal it Logo](public/assets/journal_it_logo.jpg)

**منصة التحرير الإخباري الذكية لتحويل المقابلات الصوتية والمرئية إلى تقارير صحفية معتمدة**  
**Smart Editorial Application Converting Interview Audio & Video Snippets into Authoritative News Reports**

[![Platform Version](https://img.shields.io/badge/Platform%20Version-1.0.0-crimson.svg)](#)
[![AI Engine](https://img.shields.io/badge/AI%20Model-Gemini%203.8%20Flash-blue.svg)](#)
[![Stack](https://img.shields.io/badge/Stack-Pure%20Node.js%20%2F%20Next.js-success.svg)](#)
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
**صَحِّف (Journal it)** is a streamlined, all-in-one AI newsroom application developed by **msoms.ai** (2026). It transforms raw interview audio and video recordings into concise, high-impact news wire reports written in flowing narrative paragraphs.

The entire platform is built as a **pure Next.js (Node.js)** full-stack application. It requires **no Python, no background worker processes, and no external databases**. Everything is powered directly through native API routes connected to Google's latest multimodal **Gemini 3.8 Flash** engine.

---

### 2. Core Features & Simple Workflow

1. **Multi-File Audio & Video Upload:** Batch ingestion of `.mp3`, `.wav`, `.m4a`, `.mp4`, `.mov`, `.webm` via a clean drag-and-drop or single-button interface.
2. **Multimodal Speech Transcription:** Direct native integration with Google Gemini 3.8 Flash, featuring real-time progress tracking (0%–100%).
3. **Explicit Speaker Recognition:** The AI extracts and attributes each speaker by real full name, title, and organization whenever introduced or addressed.
4. **Plain One-Shot Report Synthesis:** Produces formal, source-based narrative paragraphs with:
   - **No titles, no headlines, and no subtitles.**
   - Removal of conversational filler, verbal tics, and isolated quotes.
   - Clear third-person attribution detailing what each person said and thinks.
5. **Quick Publishing:** One-click clipboard copying and print-ready broadsheet styling.
6. **Unified Dubai Typography:** Full Arabic & English support with Dubai Font (`Dubai-Regular`, `Dubai-Medium`, `Dubai-Bold`, `Dubai-Light`) and Dark/Light mode.

---

### 3. Architecture & Tech Stack

- **Framework:** Next.js 14 (App Router) / Node.js
- **Styling & Icons:** Tailwind CSS, Lucide React, Dubai Font Family
- **AI Intelligence:** Google Gemini 3.8 Flash Multimodal Engine (Direct REST API)
- **Deployment:** Single standalone Node.js server (`server.js` or `npm start`) ready for Plesk, cPanel, or VPS.

---

### 4. Repository Structure

```text
journal_it/
├── public/
│   ├── assets/            # Logo & branding assets
│   └── fonts/             # Dubai Font family (.ttf)
├── src/
│   ├── app/
│   │   ├── api/
│   │   │   ├── transcribe/         # Native Gemini audio/video transcription
│   │   │   └── synthesize-report/  # Native Gemini news report synthesis
│   │   ├── layout.tsx              # Root HTML & metadata layout
│   │   └── page.tsx                # Main 4-stage newsroom studio
│   ├── components/                 # Minimalist Header & Footer
│   ├── lib/                        # API client & bilingual dictionaries
│   └── styles/                     # Tailwind & Dubai @font-face CSS
├── .env.example                    # Environment template
├── next.config.js                  # Next.js configuration
├── package.json                    # Single Node.js package manifest
├── server.js                       # Production Node.js server for Plesk
└── README.md                       # Bilingual documentation
```

---

### 5. Setup & Local Run

#### Step 1: Install Dependencies
```bash
npm install
```

#### Step 2: Configure Environment
Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```
Add your Gemini API key:
```env
GEMINI_API_KEY=your_gemini_api_key_here
GEMINI_MODEL_DEFAULT=gemini-3.8-flash
```

#### Step 3: Run Locally
```bash
npm run build
npm start
```
Open [http://localhost:3000](http://localhost:3000) in your browser.

---

### 6. Plesk Deployment Guide (Zero Configuration)

1. **Git Pull:** In Plesk > **Git**, pull the latest repository.
2. **Plesk Node.js Settings:**
   - **Document Root:** `public`
   - **Application Root:** `/` (subdomain root)
   - **Application Startup File:** `server.js`
   - **Node.js Version:** 18.x, 20.x, or 22.x
3. **Environment Variables:**
   - In Plesk Node.js, add:
     - `GEMINI_API_KEY`: Your Google Gemini API key
     - `GEMINI_MODEL_DEFAULT`: `gemini-3.8-flash`
4. Click **NPM Install**, then **Restart**.

---

<br />
<hr />
<br />

<a name="التوثيق-باللغة-العربية"></a>
## التوثيق باللغة العربية

### 1. نظرة عامة
**صَحِّف (Journal it)** هي منصة ذكاء اصطناعي تحريرية مبسطة ومتكاملة طُوّرت ضمن مبادرات **msoms.ai** لعام 2026. تهدف المنصة إلى تحويل التسجيلات الصوتية والمرئية للمقابلات والمؤتمرات الصحفية إلى **تقارير إخبارية مباشرة مؤلفة من فقرات صحفية متصلة** ومبنية على المصادر وفق أعلى معايير الصياغة المعتمدة.

المنصة مبنية بالكامل كـ **تطبيق Next.js / Node.js موحد وخفيف جداً، دون الحاجة لبايثون أو خوادم خلفية منفصلة أو قواعد بيانات معقدة**. تتم جميع عمليات المعالجة مباشرة عبر واجهات برمجية مدمجة تتصل بمحرك **Gemini 3.8 Flash**.

---

### 2. خطوات الاستخدام البسيطة

1. **رفع الملفات:** رفع مقاطع صوت وفيديو متعددة دفعة واحدة (`.mp3`, `.wav`, `.m4a`, `.mp4`, `.mov`, `.webm`).
2. **التفريغ الذكي:** معالجة صوتية فائقة الدقة عبر Gemini 3.8 Flash مع شريط تقدم مباشر (0% - 100%).
3. **التعرف على المتحدثين:** استخراج الأسماء الصريحة والألقاب الرسمية لكل شخص يتحدث في المقابلة تلقائياً.
4. **صياغة التقرير الإخباري (One-Shot):**
   - تقرير مؤلف حصراً من فقرات صحفية متصلة.
   - **بدون أي عناوين رئيسية أو فرعية أو ترويسات أفقية.**
   - ذكر أسماء المتحدثين وما قالوه ورؤاهم وتحليلاتهم بأسلوب صحفي رصين.
   - تنقية النص من الحشو والعبارات الشفهية والاقتباسات المتناثرة.
5. **النشر:** نسخ كامل التقرير بضغطة زر واحدة أو طباعته بتنسيق صحفي أنيق بخط دبي.

---

### 3. دليل النشر على خادم Plesk في 3 خطوات بسيطة

1. **سحب التحديثات:** من لوحة Plesk داخل صفحة **Git**، اضغط على **Pull Updates**.
2. **إعدادات Node.js في Plesk:**
   - **Document Root:** اختر المجلد `public`
   - **Application Root:** المجلد الرئيسي للنطاق الفرعي `/`
   - **Application Startup File:** اكتب `server.js`
   - **Node.js version:** اختر إصدار حديث (18 أو 20 وما فوق).
3. **متغيرات البيئة (Custom environment variables):**
   - أضف المتغير:
     - `GEMINI_API_KEY`: مفتاح Gemini الخاص بك.
     - `GEMINI_MODEL_DEFAULT`: `gemini-3.8-flash`.
4. اضغط **NPM Install** ثم **Restart** وسيعمل الموقع فوراً على نطاقك: **`https://sahhef.msoms.ai`**.
