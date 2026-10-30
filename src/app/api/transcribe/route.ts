import { NextRequest, NextResponse } from 'next/server';

export const maxDuration = 180;
export const dynamic = 'force-dynamic';

export async function POST(req: NextRequest) {
  try {
    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey || apiKey.length < 10) {
      return NextResponse.json(
        { error: 'GEMINI_API_KEY is not configured or invalid in environment.' },
        { status: 500 }
      );
    }

    const formData = await req.formData();
    const file = formData.get('file') as File | null;
    const language = (formData.get('language') as string) || 'ar';

    if (!file) {
      return NextResponse.json({ error: 'No media file provided' }, { status: 400 });
    }

    let mimeType = file.type || '';
    const ext = file.name.split('.').pop()?.toLowerCase();
    if (!mimeType || mimeType === 'application/octet-stream') {
      if (ext === 'mp3') mimeType = 'audio/mp3';
      else if (ext === 'wav') mimeType = 'audio/wav';
      else if (ext === 'm4a') mimeType = 'audio/m4a';
      else if (ext === 'mp4') mimeType = 'video/mp4';
      else if (ext === 'mov') mimeType = 'video/quicktime';
      else if (ext === 'webm') mimeType = 'video/webm';
      else mimeType = 'audio/mpeg';
    }

    const arrayBuffer = await file.arrayBuffer();
    const buffer = Buffer.from(arrayBuffer);

    const transcriptionPrompt =
      'You are a professional newsroom verbatim audio transcriber for an official news agency. ' +
      'Listen to this audio/video recording very carefully and transcribe all spoken words accurately and cleanly ' +
      'in the spoken language. ' +
      'CRITICAL SPEAKER IDENTIFICATION REQUIREMENT: Identify and clearly label each speaker with their REAL FULL NAME and TITLE ' +
      'whenever they introduce themselves, are addressed by another speaker, or are mentioned in the recording ' +
      "(for example: 'د. أحمد سالم:', 'سارة محمد:', or 'المهندس راشد الكعبي:'). " +
      "If an interviewer introduces an interviewee, immediately associate that person's exact name with their speech. " +
      "Do NOT use vague generic placeholders like 'Speaker 1' or 'المتحدث' whenever any real name or identity can be derived from the audio. " +
      'Preserve all real names, organizations, facts, figures, and statements with the highest fidelity.';

    let parts: any[] = [];

    // Files <= 15MB: use inline base64
    if (buffer.length <= 15 * 1024 * 1024) {
      const base64Data = buffer.toString('base64');
      parts = [
        { inline_data: { mime_type: mimeType, data: base64Data } },
        { text: transcriptionPrompt }
      ];
    } else {
      // Large files (> 15MB): use Gemini Files API
      const startUrl = `https://generativelanguage.googleapis.com/upload/v1beta/files?key=${apiKey}`;
      const startRes = await fetch(startUrl, {
        method: 'POST',
        headers: {
          'X-Goog-Upload-Protocol': 'resumable',
          'X-Goog-Upload-Command': 'start',
          'X-Goog-Upload-Header-Content-Length': buffer.length.toString(),
          'X-Goog-Upload-Header-Content-Type': mimeType,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ file: { display_name: file.name } }),
      });

      if (!startRes.ok) {
        const err = await startRes.text();
        throw new Error(`Failed to initiate file upload with Gemini: ${err}`);
      }

      const uploadUrl = startRes.headers.get('X-Goog-Upload-URL');
      if (!uploadUrl) {
        throw new Error('Failed to get Gemini upload URL');
      }

      const uploadRes = await fetch(uploadUrl, {
        method: 'POST',
        headers: {
          'Content-Length': buffer.length.toString(),
          'X-Goog-Upload-Command': 'upload, finalize',
          'X-Goog-Upload-Offset': '0',
        },
        body: buffer,
      });

      if (!uploadRes.ok) {
        const err = await uploadRes.text();
        throw new Error(`Failed to upload file content to Gemini: ${err}`);
      }

      const uploadInfo = await uploadRes.json();
      const fileUri = uploadInfo.file?.uri;
      if (!fileUri) {
        throw new Error('No file URI returned from Gemini Files API');
      }

      parts = [
        { file_data: { file_uri: fileUri, mime_type: mimeType } },
        { text: transcriptionPrompt }
      ];
    }

    const model = process.env.GEMINI_MODEL_DEFAULT || 'gemini-3.8-flash';
    const generateUrl = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;

    const res = await fetch(generateUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ contents: [{ parts }] }),
    });

    if (!res.ok) {
      const err = await res.text();
      throw new Error(`Gemini generateContent error (${res.status}): ${err}`);
    }

    const resultJson = await res.json();
    const candidate = resultJson.candidates?.[0];
    const textPart = candidate?.content?.parts?.[0]?.text;
    const transcript = textPart ? textPart.trim() : '';

    return NextResponse.json({
      status: 'completed',
      transcript,
      text: transcript,
      filename: file.name,
    });
  } catch (error: any) {
    console.error('Transcription route error:', error);
    return NextResponse.json(
      { error: error.message || 'Internal transcription error' },
      { status: 500 }
    );
  }
}
