# Quality Assurance & Testing Specification

---

## 1. Test Strategy & Coverage Targets

Journal it enforces rigorous testing across 4 dimensions:
1. **Unit Testing (85%+ code coverage):** API route handlers, Pydantic data sanitizers, prompt assemblers, and format converters (`.docx` and Google Docs batch updates).
2. **Audio/Video Media Ingestion Testing:** Verification of chunked streaming, file type detection, and corrupted media rejection.
3. **End-to-End (E2E) Browser & Webview Tests:** Automated Playwright test suite verifying the complete flow from file drop to article export in both Arabic and English.
4. **Security & Guardrail Verification:** Automated prompt injection attempts to confirm system instructions cannot be bypassed by malicious audio transcriptions.

---

## 2. Backend Unit & Integration Tests (PyTest)

```python
# apps/api/tests/test_gemini_service.py
import pytest
from unittest.mock import AsyncMock, patch
from src.services.gemini_service import GeminiJournalismEngine

@pytest.mark.asyncio
async def test_inverted_pyramid_arabic_generation():
    engine = GeminiJournalismEngine(api_key="AIzaSy_fake_test_key")
    
    mock_transcript = """
    المتحدث 1 (أحمد): سيادة الوزير، متى سيبدأ تشغيل مستودع الأدوية المركزي؟
    المتحدث 2 (الوزير): سنبدأ التشغيل التجريبي يوم الإثنين القادم، وسيوفر 200 فرصة عمل.
    """

    with patch.object(engine, "_call_gemini", new_callable=AsyncMock) as mock_gemini:
        mock_gemini.return_value = {
            "headline": "وزير الصحة يعلن تشغيل المستودع المركزي للأدوية الإثنين القادم",
            "subhead": "المشروع يوفر 200 فرصة عمل مباشرة",
            "lead_paragraph": "أعلن وزير الصحة عن بدء التشغيل التجريبي للمستودع الطبي المركزي يوم الإثنين القادم.",
            "quotes": ["سنبدأ التشغيل التجريبي يوم الإثنين القادم"]
        }

        result = await engine.generate_news_article(
            transcript_text=mock_transcript,
            language="ar",
            editorial_style="inverted_pyramid"
        )

        assert "وزير الصحة" in result["headline"]
        assert len(result["quotes"]) > 0
        assert result["lead_paragraph"] != ""
```

---

## 3. End-to-End Testing (Playwright)

```typescript
// apps/web/tests/e2e/article_flow.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Journal it - Senior Journalist End-to-End Flow', () => {
  test('should ingest audio, switch to Arabic, and export to Word', async ({ page }) => {
    // 1. Visit landing page
    await page.goto('/ar');
    
    // Check senior-accessible masthead
    await expect(page.locator('h1')).toContainText('جورنال إت');

    // 2. Upload test interview audio
    const fileChooserPromise = page.waitForEvent('filechooser');
    await page.click('button:has-text("تحميل تسجيل صوتي أو فيديو")');
    const fileChooser = await fileChooserPromise;
    await fileChooser.setFiles('tests/fixtures/sample_interview.mp3');

    // 3. Confirm language & trigger processing
    await page.click('button:has-text("تحليل وصياغة التقرير الصحفي")');

    // 4. Verify generated newspaper proof
    await expect(page.locator('#article-headline')).toBeVisible({ timeout: 60000 });
    await expect(page.locator('#article-lead')).toBeVisible();

    // 5. Test Copy Text action
    await page.click('button:has-text("نسخ التقرير")');
    await expect(page.locator('.toast')).toContainText('تم نسخ التقرير بنجاح');

    // 6. Test Word Export trigger
    const downloadPromise = page.waitForEvent('download');
    await page.click('button:has-text("تصدير ملف Word")');
    const download = await downloadPromise;
    expect(download.suggestedFilename()).toContain('.docx');
  });
});
```

---

## 4. CI/CD Pipeline Quality Gates (GitHub Actions)

```yaml
# .github/workflows/ci.yml
name: Journal it CI Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  backend-quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up Python 3.11
        uses: actions/setup-python@v5
        with:
          python-version: "3.11"
      - name: Install dependencies
        run: |
          cd apps/api
          pip install -r requirements.txt
          pip install pytest pytest-cov ruff black
      - name: Lint with Ruff
        run: ruff check apps/api
      - name: Run PyTest with Coverage
        run: |
          cd apps/api
          pytest --cov=src --cov-fail-under=85

  frontend-quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up Node.js 20
        uses: actions/setup-node@v4
        with:
          node-version: 20
      - name: Install pnpm
        uses: pnpm/action-setup@v3
        with:
          version: 9
      - name: Install dependencies
        run: pnpm install
      - name: Run ESLint & TypeCheck
        run: |
          pnpm run lint
          pnpm run typecheck
```
