export async function transcribeMediaFile(
  file: File,
  language: string = "ar"
): Promise<{ status: string; transcript: string; filename: string }> {
  const formData = new FormData();
  formData.append("file", file);
  formData.append("language", language);

  const res = await fetch("/api/transcribe", {
    method: "POST",
    body: formData,
  });

  if (!res.ok) {
    const errorJson = await res.json().catch(() => ({}));
    const errorDetail = errorJson.error || (await res.text().catch(() => "Unknown error"));
    throw new Error(`Transcription failed: ${errorDetail}`);
  }

  return await res.json();
}

export async function synthesizeUaeReport(params: {
  transcripts: string[];
  title?: string;
  language?: string;
  byline?: string;
  dateline?: string;
}) {
  const res = await fetch("/api/synthesize-report", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(params),
  });

  if (!res.ok) {
    const errorJson = await res.json().catch(() => ({}));
    const errorDetail = errorJson.error || (await res.text().catch(() => "Unknown error"));
    throw new Error(`Report synthesis failed: ${errorDetail}`);
  }

  return await res.json();
}
