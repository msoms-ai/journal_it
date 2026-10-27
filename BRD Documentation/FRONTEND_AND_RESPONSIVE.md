# Frontend Architecture, Bilingual Engine & Senior-Friendly UI/UX

---

## 1. Senior Journalist UX Philosophy

Veteran and senior journalists possess deep editorial acumen but often experience friction with modern, cluttered software (small gray fonts, low contrast, hidden menus, multi-nested modal dialogs).

### Core Human Factors Guidelines
1. **Physical Broadsheet Aesthetic:** High-contrast, glare-free newsprint styling that replicates the tactile familiarity of print journalism rather than feeling like a sterile software dashboard.
2. **56px Touch Target Minimum:** All interactive buttons (Record, Upload, Language Toggle, Theme Toggle, Copy, Share, Export) have oversized physical hit zones suitable for shaky or aging hands on mobile touchscreens.
3. **Generous Scalable Typography:** Default body copy is 18px (scalable up to 26px via an in-app `A- / A+` tactile zoom slider). Headings are set in authentic editorial serif typefaces with strong, legible letterforms.
4. **Zero-Confusion 3-Step Mental Model:**
   - **Step 1:** Ingest interview (Forward from WhatsApp, record live, or select file).
   - **Step 2:** Select language (**العربية** or **English**) & confirm byline.
   - **Step 3:** Review news report, with immediate large buttons to **Copy Text**, **Share to Phone App**, **Download Word (.docx)**, or **Open in Google Docs**.

---

## 2. Bilingual Architecture: Dual Engine (Arabic RTL & English LTR)

Journal it is built from the ground up as a native bi-directional, bilingual editorial system.

### 2.1 Locale Routing & Layout Engine
- Built with `next-intl` under Next.js 14 App Router: `apps/web/src/app/[locale]/...`
- Root layout dynamically assigns `<html lang={locale} dir={locale === 'ar' ? 'rtl' : 'ltr'}>`.
- **CSS Logical Properties:** All margins, paddings, borders, and flex alignments use directional CSS logical properties (`margin-inline-start`, `padding-inline-end`, `border-inline-start`) ensuring seamless horizontal mirroring without layout breakage.

### 2.2 Editorial Typographic Pairing

| Element | English (LTR) | Arabic (RTL) | Typographic Rationale |
| :--- | :--- | :--- | :--- |
| **Headline Font** | *Playfair Display* / *Georgia* | *Amiri* / *Cairo* (Bold Serif) | Classic news headline weight, authoritative serif presence. |
| **Body Font** | *Merriweather* / *Newsreader* | *Noto Naskh Arabic* / *Amiri* | High legibility at 18px+ for extended reading and proofing. |
| **UI & Controls** | *Inter* / System Sans | *Tajawal* / *Cairo* | Clean, open counter-forms for buttons, menus, and badges. |
| **Mono / Timestamps**| *JetBrains Mono* | *JetBrains Mono* (Latin numerals) | Monospaced alignment for audio timestamps and diarization tags. |

### 2.3 Journalistic Style Adapters
- **Arabic Engine:** Implements the inverted pyramid format following Arab News Agency (وكالة أنباء الشرق الأوسط) and *Al-Ahram* editorial standards. Uses authentic journalistic attribution phrases (*صرّح، وأكد، وأوضح، واختتم بالقول*) and formal Naskh quotation marks (`« »`).
- **English Engine:** Implements the Associated Press (AP) Stylebook standard. Neutral third-person voice, strict attribution verbs (*said, stated, added*), and standard curly quotation marks (`“ ”`).

---

## 3. Dark & Light Theme Architecture ("Day & Night Newsroom")

To support investigative journalists working in varied lighting environments—from daylight field reporting to late-night newsroom filing—Journal it features a fully switchable **Light & Dark Theme** system designed to prevent eye fatigue while preserving WCAG AAA contrast compliance (exceeding 7:1 contrast ratio).

### 3.1 Design Tokens & Color Palette

| Token / Role | Light Mode ("Morning Broadsheet") | Dark Mode ("Night Press / Midnight Newsprint") | WCAG Ratio |
| :--- | :--- | :--- | :--- |
| `--bg-canvas` | `#FBF9F5` (Newsprint Ivory / Bone) | `#0E1013` (Deep Obsidian / Black Ink) | AAA Base |
| `--bg-surface` | `#FFFFFF` (Pure White Paper) | `#181B20` (Dark Broadsheet Slate) | AAA Base |
| `--bg-subtle` | `#F2EFE9` (Warm Gray Proofing Card) | `#22272E` (Charcoal Paper Layer) | AAA Base |
| `--text-primary` | `#111315` (Deep Carbon Black Ink) | `#F4F2EC` (Warm Antique Off-White) | > 12:1 |
| `--text-secondary` | `#4A4F55` (Printer's Graphite) | `#A3AAB2` (Muted Press Gray) | > 7.5:1 |
| `--accent-crimson` | `#8B0000` (Editorial Deep Crimson) | `#FF5C5C` (Luminous Press Ruby) | > 5.5:1 |
| `--accent-byline` | `#004080` (Navy Editorial Ink) | `#60A5FA` (Electric Editorial Azure) | > 6:1 |
| `--border-rule` | `#D9D4C7` (Vintage Double Rule Gray)| `#2D333B` (Dark Etched Rule) | Structural |
| `--audio-wave` | `#8B0000` (Crimson Audio Needle) | `#FF7B7B` (High-Vis Audio Waveform) | Accessible |

### 3.2 Tailwind CSS Configuration (`apps/web/tailwind.config.ts`)
```typescript
import type { Config } from 'tailwindcss';

const config: Config = {
  darkMode: 'class', // Controlled via 'class' on <html> tag
  content: ['./src/**/*.{js,ts,jsx,tsx,mdx}'],
  theme: {
    extend: {
      colors: {
        canvas: 'var(--bg-canvas)',
        surface: 'var(--bg-surface)',
        subtle: 'var(--bg-subtle)',
        ink: {
          primary: 'var(--text-primary)',
          secondary: 'var(--text-secondary)',
        },
        editorial: {
          crimson: 'var(--accent-crimson)',
          navy: 'var(--accent-byline)',
          rule: 'var(--border-rule)',
        },
      },
      fontFamily: {
        headlineEn: ['var(--font-headline-en)', 'Playfair Display', 'serif'],
        headlineAr: ['var(--font-headline-ar)', 'Amiri', 'serif'],
        bodyEn: ['var(--font-body-en)', 'Merriweather', 'serif'],
        bodyAr: ['var(--font-body-ar)', 'Noto Naskh Arabic', 'serif'],
      },
      minHeight: {
        'touch-target': '56px',
      },
      minWidth: {
        'touch-target': '56px',
      },
    },
  },
  plugins: [],
};

export default config;
```

### 3.3 Theme Switcher Implementation (`next-themes`)
The theme state is managed via `next-themes` with three user-selectable modes: `light`, `dark`, and `system`.

```tsx
// apps/web/src/components/ThemeToggle.tsx
'use client';

import React from 'react';
import { useTheme } from 'next-themes';
import { Sun, Moon, Monitor } from 'lucide-react';
import { useTranslations } from 'next-intl';

export function ThemeToggle() {
  const { theme, setTheme } = useTheme();
  const t = useTranslations('theme');

  return (
    <div className="inline-flex items-center p-1 bg-subtle border border-editorial-rule rounded-full min-h-[56px]">
      <button
        onClick={() => setTheme('light')}
        aria-label={t('light_mode')}
        aria-pressed={theme === 'light'}
        className={`flex items-center gap-2 px-4 py-3 rounded-full text-base font-medium transition-colors min-h-[48px] ${
          theme === 'light'
            ? 'bg-surface text-ink-primary shadow-sm border border-editorial-rule'
            : 'text-ink-secondary hover:text-ink-primary'
        }`}
      >
        <Sun className="w-5 h-5 text-editorial-crimson" />
        <span className="hidden sm:inline">{t('light')}</span>
      </button>

      <button
        onClick={() => setTheme('dark')}
        aria-label={t('dark_mode')}
        aria-pressed={theme === 'dark'}
        className={`flex items-center gap-2 px-4 py-3 rounded-full text-base font-medium transition-colors min-h-[48px] ${
          theme === 'dark'
            ? 'bg-surface text-ink-primary shadow-sm border border-editorial-rule'
            : 'text-ink-secondary hover:text-ink-primary'
        }`}
      >
        <Moon className="w-5 h-5 text-editorial-crimson" />
        <span className="hidden sm:inline">{t('dark')}</span>
      </button>

      <button
        onClick={() => setTheme('system')}
        aria-label={t('system_preference')}
        aria-pressed={theme === 'system'}
        className={`flex items-center gap-2 px-3 py-3 rounded-full text-base font-medium transition-colors min-h-[48px] ${
          theme === 'system'
            ? 'bg-surface text-ink-primary shadow-sm border border-editorial-rule'
            : 'text-ink-secondary hover:text-ink-primary'
        }`}
      >
        <Monitor className="w-5 h-5" />
      </button>
    </div>
  );
}
```

### 3.4 Theme Persistence & Profile Sync
1. **Client-Side:** Stored in `localStorage` under `journalit_theme` for immediate zero-flash rendering (`suppressHydrationWarning` on `<html>`).
2. **Server-Side:** When authenticated, theme changes are asynchronously synced to `PATCH /api/v1/users/me/preferences` (`preferred_theme`), ensuring that a journalist logging in from a phone or newsroom desktop has their preferred visual environment preserved.

---

## 4. Flutter Mobile Wrapper Architecture (`journal_it_mobile`)

The mobile application wraps the responsive Next.js web application using `flutter_inappwebview` with full access to native hardware features, OS intent receivers, and OS dark/light mode synchronization.

### Flutter Project Structure
```text
apps/mobile_flutter/
├── lib/
│   ├── bridge/
│   │   └── webview_bridge.dart       # JavaScript Handlers (share, haptic, file save, theme)
│   ├── services/
│   │   ├── share_intent_service.dart # Listens to WhatsApp share intents
│   │   └── theme_sync_service.dart   # Relays iOS/Android system dark mode changes
│   ├── screens/
│   │   └── main_webview_screen.dart  # InAppWebView with offline fallback
│   └── main.dart
├── android/app/src/main/AndroidManifest.xml
└── ios/Runner/Info.plist
```

### Native WhatsApp Intent Filter Configuration

#### Android (`AndroidManifest.xml`)
```xml
<activity
    android:name=".MainActivity"
    android:launchMode="singleTask"
    android:theme="@style/LaunchTheme"
    android:configChanges="orientation|keyboardHidden|keyboard|screenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
    android:hardwareAccelerated="true"
    android:windowSoftInputMode="adjustResize">

    <!-- Intent filter to accept shared audio & video from WhatsApp -->
    <intent-filter>
        <action android:name="android.intent.action.SEND" />
        <category android:name="android.intent.category.DEFAULT" />
        <data android:mimeType="audio/*" />
        <data android:mimeType="video/*" />
    </intent-filter>
    <intent-filter>
        <action android:name="android.intent.action.SEND_MULTIPLE" />
        <category android:name="android.intent.category.DEFAULT" />
        <data android:mimeType="audio/*" />
        <data android:mimeType="video/*" />
    </intent-filter>
</activity>
```

#### Flutter Intent & Theme Dispatcher (`share_intent_service.dart`)
```dart
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class ShareIntentService {
  static void init(InAppWebViewController webViewController, BuildContext context) {
    // Listen for shared media while app is running
    ReceiveSharingIntent.instance.getMediaStream().listen((List<SharedMediaFile> files) {
      if (files.isNotEmpty) {
        _dispatchMediaToWebView(webViewController, files.first);
      }
    });

    // Handle shared media when app was launched from closed state
    ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> files) {
      if (files.isNotEmpty) {
        _dispatchMediaToWebView(webViewController, files.first);
      }
    });
  }

  static void _dispatchMediaToWebView(InAppWebViewController controller, SharedMediaFile file) {
    controller.evaluateJavascript(source: '''
      if (window.onWhatsAppMediaReceived) {
        window.onWhatsAppMediaReceived({
          path: "${file.path}",
          type: "${file.type}",
          name: "${file.path.split('/').last}"
        });
      }
    ''');
  }

  static void syncSystemTheme(InAppWebViewController controller, Brightness brightness) {
    final mode = brightness == Brightness.dark ? 'dark' : 'light';
    controller.evaluateJavascript(source: '''
      if (window.onSystemThemeChanged) {
        window.onSystemThemeChanged("$mode");
      }
    ''');
  }
}
```

---

## 5. Responsive Layout Breakpoints

- **Mobile Viewport (320px – 480px):** Single-column stacked broadsheet; oversized action bar docked to bottom of viewport with 56px touch height; high-contrast masthead; integrated language and dark/light switcher.
- **Tablet / iPad Viewport (768px – 1024px):** Two-column editorial layout: Left column hosts audio/video waveform playback and verbatim transcript quotes; Right column displays publication-ready news article proof.
- **Desktop Broadsheet (1200px+):** Three-column newsroom layout: Source Interview & Media Player | Center Broadsheet Proof | Right Sidebar with Export Controls, Gemini Prompt Configuration, Theme & Language Settings, and Version History.
