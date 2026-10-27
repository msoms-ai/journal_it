"use strict";(()=>{var e={};e.id=829,e.ids=[829],e.modules={399:e=>{e.exports=require("next/dist/compiled/next-server/app-page.runtime.prod.js")},517:e=>{e.exports=require("next/dist/compiled/next-server/app-route.runtime.prod.js")},5022:(e,t,r)=>{r.r(t),r.d(t,{originalPathname:()=>m,patchFetch:()=>E,requestAsyncStorage:()=>h,routeModule:()=>u,serverHooks:()=>g,staticGenerationAsyncStorage:()=>d});var a={};r.r(a),r.d(a,{POST:()=>c,dynamic:()=>l,maxDuration:()=>p});var i=r(9303),n=r(8716),s=r(670),o=r(7070);let p=120,l="force-dynamic";async function c(e){try{let t=process.env.GEMINI_API_KEY;if(!t||t.length<10)return o.NextResponse.json({error:"GEMINI_API_KEY is not configured or invalid in environment."},{status:500});let r=await e.json(),a=r.transcripts||[],i=r.language||"ar",n=a.join("\n\n---\n\n").replace(/SYSTEM\s*:/gi,"").replace(/Human\s*:/gi,"").replace(/AI\s*:/gi,"").replace(/\[INST\]/gi,"").replace(/\[\/INST\]/gi,"").replace(/```system/gi,"").trim(),s=`
You are an award-winning senior news wire editor specializing in UAE news agency and national broadsheet journalism. Your task is to synthesize the provided source recordings into a cohesive, formal newspaper wire report written strictly as a plain, one-shot narrative in flowing paragraphs based on the given sources.

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
${n}
</interview_transcripts>

TARGET LANGUAGE: ${i}

Return ONLY a valid JSON object with this exact structure:
{
  "report_text": "Plain one-shot report written strictly in flowing narrative paragraphs based on the sources, with NO titles, NO subtitles, and NO section headings. Explicitly mention each speaker by their real name (e.g., 'أكد الدكتور سالم المنصوري أن...', 'وبيّن المهندس محمد الكعبي أنه يرى...'), detailing what they said and what they think in formal journalistic prose.",
  "word_count": 350
}
`,p=process.env.GEMINI_MODEL_DEFAULT||"gemini-3.8-flash",l=`https://generativelanguage.googleapis.com/v1beta/models/${p}:generateContent?key=${t}`,c=await fetch(l,{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({contents:[{parts:[{text:s}]}],generationConfig:{responseMimeType:"application/json"}})});if(!c.ok){let e=await c.text();throw Error(`Gemini generateContent report error (${c.status}): ${e}`)}let u=await c.json(),h=u.candidates?.[0]?.content?.parts?.[0]?.text?.trim()||"{}";h.startsWith("```json")?h=h.replace(/```json/g,"").replace(/```/g,"").trim():h.startsWith("```")&&(h=h.replace(/```/g,"").trim());let d=JSON.parse(h),g=(d.report_text||"").split("\n\n").map(e=>e.trim().replace(/^###\s*|^##\s*|^#\s*/,"")).filter(Boolean).join("\n\n");return o.NextResponse.json({report_text:g,body_markdown:g,headline:"",subhead:"",byline:"ar"===i?"التحرير الإخباري":"Editorial News Desk",dateline:"ar"===i?"وام — مكتب الأخبار":"News Wire Desk",word_count:d.word_count||g.split(/\s+/).length})}catch(e){return console.error("Synthesis route error:",e),o.NextResponse.json({error:e.message||"Internal synthesis error"},{status:500})}}let u=new i.AppRouteRouteModule({definition:{kind:n.x.APP_ROUTE,page:"/api/synthesize-report/route",pathname:"/api/synthesize-report",filename:"route",bundlePath:"app/api/synthesize-report/route"},resolvedPagePath:"C:\\AntiGravity_Apps\\Journal_it\\src\\app\\api\\synthesize-report\\route.ts",nextConfigOutput:"",userland:a}),{requestAsyncStorage:h,staticGenerationAsyncStorage:d,serverHooks:g}=u,m="/api/synthesize-report/route";function E(){return(0,s.patchFetch)({serverHooks:g,staticGenerationAsyncStorage:d})}}};var t=require("../../../webpack-runtime.js");t.C(e);var r=e=>t(t.s=e),a=t.X(0,[276,972],()=>r(5022));module.exports=a})();