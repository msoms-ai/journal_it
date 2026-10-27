import { NextRequest, NextResponse } from 'next/server';

export const maxDuration = 120;
export const dynamic = 'force-dynamic';

function sanitizeInput(text: string): string {
  return text
    .replace(/SYSTEM\s*:/gi, '')
    .replace(/Human\s*:/gi, '')
    .replace(/AI\s*:/gi, '')
    .replace(/\[INST\]/gi, '')
    .replace(/\[\/INST\]/gi, '')
    .replace(/```system/gi, '')
    .trim();
}

export async function POST(req: NextRequest) {
  try {
    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey || apiKey.length < 10) {
      return NextResponse.json(
        { error: 'GEMINI_API_KEY is not configured or invalid in environment.' },
        { status: 500 }
      );
    }

    const payload = await req.json();
    const transcriptsList: string[] = payload.transcripts || [];
    const language: string = payload.language || 'ar';

    const combinedText = sanitizeInput(transcriptsList.join('\n\n---\n\n'));

    const systemInstruction =
      'You are an award-winning senior news wire editor specializing in UAE news agency and national broadsheet journalism. ' +
      'Your task is to synthesize the provided source recordings into a cohesive, formal newspaper wire report written strictly as a plain, one-shot narrative in flowing paragraphs based on the given sources.';

    const prompt = `
${systemInstruction}

STRICT EDITORIAL REQUIREMENTS:
1. NO TITLES, NO HEADLINES, NO SUBTITLES, NO SECTION HEADINGS:
   - Absolutely DO NOT generate any headline, title, subtitle, deck, header, or section subheadings (do NOT use '###' or any titles whatsoever).
   - The final output MUST be a plain, one-shot report consisting purely of cohesive, flowing journalistic paragraphs.

2. EXTRACT AND STATE REAL SPEAKER NAMES (CRITICAL REQUIREMENT):
   - You MUST extract and explicitly state the REAL FULL NAME and official title of each person who was talking (e.g. 'أكد الدكتور سلطان النعيمي...', 'وأوضح المهندس راشد الشامسي أنه يرى... مشيراً إلى أنه يعتقد...').
   - Scrutinize the source transcripts, speaker labels, introductions, greetings, questions, and references to locate and attribute their exact names.
   - NEVER use anonymous or generic placeholders like 'المتحدث', 'أحد المسؤولين', 'المسؤولون', 'المصدر', or 'Speaker'. Every speaker must be explicitly identified by their actual name.

3. DETAIL WHAT THEY SAID AND WHAT THEY THINK (NO SIGHTING OR RAW SPOKEN PHRASES):
   - Synthesize each person's statements into formal, authoritative third-person journalistic narrative.
   - Detail what they said, what they think, their viewpoints, assessments, strategic rationales, and perspectives.
   - Remove all conversational filler, transcript idioms, verbal tics, citations, quote callouts, and raw colloquial phrases.

4. CONTINUOUS SOURCE-BASED PARAGRAPHS:
   - Structure the report into solid, comprehensive paragraphs based on each source/speaker and strategic topic.
   - Paragraphs must flow smoothly one into another as a complete, unified wire dispatch.

SOURCE TRANSCRIPTS:
<interview_transcripts>
${combinedText}
</interview_transcripts>

TARGET LANGUAGE: ${language}

Return ONLY a valid JSON object with this exact structure:
{
  "report_text": "Plain one-shot report written strictly in flowing narrative paragraphs based on the sources, with NO titles, NO subtitles, and NO section headings. Explicitly mention each speaker by their real name (e.g., 'أكد الدكتور سالم المنصوري أن...', 'وبيّن المهندس محمد الكعبي أنه يرى...'), detailing what they said and what they think in formal journalistic prose.",
  "word_count": 350
}
`;

    const model = process.env.GEMINI_MODEL_DEFAULT || 'gemini-3.8-flash';
    const generateUrl = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;

    const res = await fetch(generateUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: { responseMimeType: 'application/json' }
      }),
    });

    if (!res.ok) {
      const err = await res.text();
      throw new Error(`Gemini generateContent report error (${res.status}): ${err}`);
    }

    const data = await res.json();
    let rawText = data.candidates?.[0]?.content?.parts?.[0]?.text?.trim() || '{}';
    if (rawText.startsWith('```json')) {
      rawText = rawText.replace(/```json/g, '').replace(/```/g, '').trim();
    } else if (rawText.startsWith('```')) {
      rawText = rawText.replace(/```/g, '').trim();
    }

    const parsed = JSON.parse(rawText);
    const reportText: string = parsed.report_text || '';
    const cleanedParas = reportText
      .split('\n\n')
      .map((p) => p.trim().replace(/^###\s*|^##\s*|^#\s*/, ''))
      .filter(Boolean);

    const finalReport = cleanedParas.join('\n\n');

    return NextResponse.json({
      report_text: finalReport,
      body_markdown: finalReport,
      headline: '',
      subhead: '',
      byline: language === 'ar' ? 'التحرير الإخباري' : 'Editorial News Desk',
      dateline: language === 'ar' ? 'وام — مكتب الأخبار' : 'News Wire Desk',
      word_count: parsed.word_count || finalReport.split(/\s+/).length,
    });
  } catch (error: any) {
    console.error('Synthesis route error:', error);
    return NextResponse.json(
      { error: error.message || 'Internal synthesis error' },
      { status: 500 }
    );
  }
}
