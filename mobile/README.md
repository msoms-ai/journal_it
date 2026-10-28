# تطبيق «صَحِّف | Journal it» — Flutter Mobile Application

تطبيق جوال أصيل (Native Mobile App) مبني بواسطة **Flutter** لنظامي **Android** و **iOS** لتحويل المقابلات والتسجيلات الميدانية (صوت وفيديو) إلى تقارير صحفية رسمية متكاملة بنمط وكالات الأنباء الإماراتية عبر التكامل المباشر والآمن مع خادم **«صَحِّف»** (`https://sahhef.msoms.ai`).

---

## 🌟 المزايا الرئيسية (Key Features)

1. **الواجهة الصحفية الأصيلة (120Hz Native UI):**
   * واجهة متجاوبة بالكامل تدعم اللغة العربية (RTL) والإنجليزية (LTR).
   * دعم المظهر الفاتح (Light Mode) والداكن (Dark Mode) وفق الهوية البصرية الرسمية للمنصة (العنابي التحريري `#8B0000`).

2. **التسجيل الصوتي المباشر للمقابلات (Live Interview Recorder):**
   * إمكانية تسجيل المقابلات والتصريحات الصحفية مباشرة من ميكروفون الهاتف في الميدان.
   * مؤقت تسجيل حي مع ترميز AAC عالي النقاوة.

3. **اختيار ملفات الصوت والفيديو (Native Media Picker):**
   * دعم اختيار تسجيلات متعددة دفعة واحدة من ذاكرة الهاتف أو خدمات التخزين السحابي (Google Drive, iCloud Files).
   * يدعم صيغ: `MP3, WAV, M4A, AAC, MP4, MOV, WEBM`.

4. **الأمان الكامل لمفاتيح الذكاء الاصطناعي (API Security):**
   * يتصل التطبيق بنقاط النهاية الآمنة في خادم المنصة (`/api/transcribe` و `/api/synthesize-report`) دون تخزين مفتاح `GEMINI_API_KEY` داخل كود الجوال، مما يمنع سرقته تماماً.

5. **المشاركة والتصدير بنقرة واحدة (Native Sharing):**
   * مشاركة التقرير المعتمد مباشرة عبر تطبيقات المراسلة والبريد (WhatsApp, Telegram, Mail, Notes) من خلال نافذة المشاركة الرسمية للنظام.

---

## 📂 هيكل المشروع (Project Structure)

```
mobile/
├── android/                  # إعدادات وصلاحيات نظام أندرويد (AndroidManifest.xml)
├── ios/                      # إعدادات وصلاحيات نظام آبل (Info.plist)
├── assets/images/            # شعار وأيقونات المنصة
├── lib/
│   ├── main.dart             # نقطة انطلاق التطبيق وإعدادات اللغات والمظهر
│   ├── config/
│   │   ├── api_config.dart   # رابط خادم المنصة (sahhef.msoms.ai)
│   │   └── app_theme.dart    # الألوان والخطوط الصحفية (Amiri / Cairo)
│   ├── models/
│   │   └── media_item.dart   # نموذج بيانات التسجيلات المرفوعة وحالتها
│   ├── services/
│   │   ├── api_service.dart  # الاتصال بالخادم للتفريغ وصياغة التقرير
│   │   ├── audio_recorder_service.dart # تسجيل الصوت من الميكروفون
│   │   └── file_picker_service.dart    # اختيار ملفات الوسائط
│   ├── screens/
│   │   ├── home_screen.dart          # شاشة الرفع والتسجيل الميداني
│   │   ├── transcribing_screen.dart  # مؤشر التفريغ والتحليل الحي
│   │   ├── review_screen.dart        # مراجعة النصوص المفرغة واختيارها
│   │   └── report_screen.dart        # عرض ومشاركة التقرير الإخباري النهائي
│   └── widgets/
│       └── app_header.dart   # الترويسة وأزرار تبديل اللغة والمظهر
└── pubspec.yaml              # حزم ومكتبات فلاتر
```

---

## 🚀 كيفية تشغيل التطبيق محلياً (How to Run Locally)

### المتطلبات الأساسية (Prerequisites):
* تثبيت **Flutter SDK** (الإصدار 3.0 فما فوق) من: [flutter.dev](https://flutter.dev).
* بيئة التطوير المفضلة: **VS Code** أو **Android Studio**.

### خطوات التشغيل:
1. افتح موجه الأوامر (Terminal) وانتقل لمجلد التطبيق:
   ```bash
   cd mobile
   ```
2. تثبيت الحزم والمكتبات:
   ```bash
   flutter pub get
   ```
3. توصيل هاتف أندرويد بالكمبيوتر (عبر USB مع تفعيل USB Debugging) أو تشغيل المحاكي (Emulator)، ثم:
   ```bash
   flutter run
   ```

---

## 📦 بناء الحزم الرسمية للمتاجر (Production Release)

### 1. متجر جوجل بلاي (Google Play Store):
لتوليد ملف الـ App Bundle المطلوب للرفع على حساب Google Play Console:
```bash
cd mobile
flutter build appbundle --release
```
الملف الناتج سيكون في المسار:
`mobile/build/app/outputs/bundle/release/app-release.aab`

### 2. متجر آبل (Apple App Store):
* **ملاحظة:** يتطلب جهاز **Mac** يحتوي على **Xcode**.
لتوليد أرشيف الـ iOS للرفع عبر Transporter أو Xcode:
```bash
cd mobile
flutter build ipa --release
```
الملف الناتج سيكون في المسار:
`mobile/build/ios/archive/Runner.xcarchive`
