export type Locale = 'ar' | 'en';

export const translations = {
  ar: {
    appName: "صَحِّف",
    appNameFull: "صَحِّف",
    appTagline: "منصة التحرير الإخباري الذكية للتسجيلات الصوتية والمرئية",
    
    // Header & Footer
    msomsLink: "MSOMS.AI",
    footerInitiative: "مبادرة ذكاء اصطناعي من msoms.ai - 2026",
    footerVersion: "إصدار المنصة 1.0.0 • النموذج: Gemini 3.8 Flash",

    // Step 1: Upload
    uploadBigButton: "اضغط لرفع التسجيلات الصوتية والمرئية (ملفات متعددة)",
    uploadSubtext: "أو اسحب وأفلت الملفات هنا • يدعم جميع صيغ الصوت والفيديو",
    uploadedFilesTitle: "قائمة الملفات المرفوعة",
    fileColName: "اسم الملف",
    fileColType: "النوع",
    fileColSize: "الحجم",
    fileColStatus: "الحالة",
    fileColAction: "حذف",
    statusReady: "جاهز للتفريغ",
    statusProcessing: "جاري التفريغ...",
    statusCompleted: "تم التفريغ",
    emptyFilesHint: "لم يتم اختيار أي ملف بعد. اضغط على الزر أعلاه للبدء.",
    clearAll: "إفراغ القائمة",
    startProcessBtn: "صَحِّف !!",

    // Step 2: Waiting Step
    transcribingTitle: "جاري تفريغ التسجيلات الصوتية وتحليل المحتوى",
    transcribingDesc: "يرجى الانتظار، المنصة تعمل الآن على استخراج وتوثيق النصوص بدقة عالية...",
    progressLabel: "نسبة الإنجاز الإجمالية",
    currentProcessing: "جاري العمل على:",

    // Step 3: Transcribed List View
    transcriptionsTitle: "النصوص المفرغة من التسجيلات",
    transcriptionsDesc: "يمكنك مراجعة النصوص المفرغة، نسخها، أو إعادة معالجة أي تسجيل، وتحديد المواد المطلوبة لإعداد التقرير الإخباري.",
    selectAll: "تحديد الكل",
    copyText: "نسخ النص",
    retranscode: "إعادة التفريغ",
    generateUaeReportBtn: "صياغة التقرير الإخباري (نمط وكالات الأنباء الإماراتية)",
    selectedCount: "ملف محدد",

    // Step 4: UAE News Report
    uaeReportTitle: "التقرير الإخباري المعتمد",
    uaeReportSub: "صياغة صحفية رصينة وفق النمط التحريري لوكالات الأنباء والصحف الإماراتية",
    copyReport: "نسخ التقرير كاملاً",
    printReport: "طباعة التقرير",
    startNew: "بدء جلسة عمل جديدة",
    copiedToast: "تم نسخ النص بنجاح إلى الحافظة",
    datelineDefault: "وام — مكتب الأخبار",
    bylineDefault: "التحرير الإخباري",

    // Settings
    lightMode: "فاتح",
    darkMode: "داكن",

    // PWA Install Prompt
    installTitle: "أضف تطبيق «صَحِّف» إلى شاشة هاتفك",
    installSubtitle: "للوصول السريع وتجربة تحرير صحفية متكاملة بلمسة واحدة",
    installBtn: "إضافة إلى الشاشة الرئيسية",
    installNotNow: "ليس الآن",
    installIosStep1: "اضغط على أيقونة المشاركة",
    installIosStep2: "ثم اختر «إضافة إلى الشاشة الرئيسية»",
  },
  en: {
    appName: "Journal it",
    appNameFull: "Journal it",
    appTagline: "Smart Editorial Newsroom Studio for Audio & Video Interviews",
    
    // Header & Footer
    msomsLink: "MSOMS.AI",
    footerInitiative: "an AI initiative by msoms.ai - 2026",
    footerVersion: "Platform Version 1.0.0 • Model: Gemini 3.8 Flash",

    // Step 1: Upload
    uploadBigButton: "Click to Upload Audio & Video Recordings (Multiple Files)",
    uploadSubtext: "or drag and drop files here • Supports all audio and video formats",
    uploadedFilesTitle: "Uploaded Media Queue",
    fileColName: "File Name",
    fileColType: "Format",
    fileColSize: "Size",
    fileColStatus: "Status",
    fileColAction: "Delete",
    statusReady: "Ready to transcribe",
    statusProcessing: "Transcribing...",
    statusCompleted: "Transcribed",
    emptyFilesHint: "No files selected yet. Click the button above to begin.",
    clearAll: "Clear All",
    startProcessBtn: "Journal it !!",

    // Step 2: Waiting Step
    transcribingTitle: "Transcribing Audio Recordings & Analyzing Content",
    transcribingDesc: "Please wait while the platform processes and transcribes your media with editorial accuracy...",
    progressLabel: "Overall Progress",
    currentProcessing: "Currently processing:",

    // Step 3: Transcribed List View
    transcriptionsTitle: "Transcribed Media Files",
    transcriptionsDesc: "Review and copy transcripts, retranscribe specific files, and select the records to compile into the news agency report.",
    selectAll: "Select All",
    copyText: "Copy Text",
    retranscode: "Retranscribe",
    generateUaeReportBtn: "Generate UAE News Agency Style Report",
    selectedCount: "files selected",

    // Step 4: UAE News Report
    uaeReportTitle: "Official News Agency Report",
    uaeReportSub: "Synthesized in the formal inverted-pyramid editorial standard of UAE national newspapers and news wire services",
    copyReport: "Copy Full Report",
    printReport: "Print Report",
    startNew: "Start New Session",
    copiedToast: "Copied successfully to clipboard",
    datelineDefault: "News Wire Desk",
    bylineDefault: "Editorial News Desk",

    // Settings
    lightMode: "Light",
    darkMode: "Dark",

    // PWA Install Prompt
    installTitle: 'Add "Journal it" to your Home Screen',
    installSubtitle: "Quick one-tap access and seamless newsroom experience on your phone",
    installBtn: "Add to Home Screen",
    installNotNow: "Not now",
    installIosStep1: "Tap the Share button",
    installIosStep2: 'Then select "Add to Home Screen"',
  }
};
