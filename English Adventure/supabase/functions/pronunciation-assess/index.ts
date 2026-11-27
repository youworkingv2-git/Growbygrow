// Supabase Edge Function: pronunciation-assess
// Proxies user-confirmed short audio (<= 30s, <= 2MB) to Microsoft Azure AI Speech
// Pronunciation Assessment REST API without exposing API keys in the Godot client.
// Child Privacy: processes audio in-memory only; never persists raw child voice audio.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const MAX_AUDIO_BYTES = 2 * 1024 * 1024; // 2 MB guard for <= 30s short-audio REST API

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), { status: 405 });
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return new Response(JSON.stringify({ error: "Missing Authorization header" }), { status: 401 });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
  const azureKey = Deno.env.get("AZURE_SPEECH_KEY") ?? "";
  const azureResource = Deno.env.get("AZURE_SPEECH_RESOURCE") ?? "";

  if (!azureKey || !azureResource) {
    return new Response(
      JSON.stringify({
        assessment_status: "provider_unavailable",
        provider: "azure_speech",
        overall_score: null,
        accuracy_score: null,
        fluency_score: null,
        completeness_score: null,
        prosody_score: null,
        word_feedback: [],
        phoneme_feedback: [],
        message_vi: "Máy chủ chưa cấu hình AZURE_SPEECH_KEY / AZURE_SPEECH_RESOURCE."
      }),
      { status: 503, headers: { "Content-Type": "application/json" } }
    );
  }

  const supabase = createClient(supabaseUrl, supabaseAnonKey, {
    global: { headers: { Authorization: authHeader } },
  });
  const { data: userData, error: userErr } = await supabase.auth.getUser();
  if (userErr || !userData?.user) {
    return new Response(JSON.stringify({ error: "Unauthorized user" }), { status: 401 });
  }

  const body = await req.json();
  const audioBase64 = String(body.audio_base64 ?? "");
  const expectedText = String(body.expected_text ?? "").trim();
  const language = body.language === "en-GB" ? "en-GB" : "en-US";
  const mimeType = String(body.mime_type ?? "audio/wav");

  if (!audioBase64 || !expectedText) {
    return new Response(JSON.stringify({ error: "audio_base64 and expected_text are required" }), { status: 400 });
  }

  const binaryStr = atob(audioBase64);
  if (binaryStr.length > MAX_AUDIO_BYTES) {
    return new Response(JSON.stringify({ error: "Audio exceeds 2MB / 30s limit" }), { status: 413 });
  }
  const audioBytes = new Uint8Array(binaryStr.length);
  for (let i = 0; i < binaryStr.length; i++) {
    audioBytes[i] = binaryStr.charCodeAt(i);
  }

  // Official Azure AI Speech Pronunciation Assessment header (Base64-encoded JSON)
  // Note: ProsodyScore is supported only on en-US per official Microsoft Learn docs.
  const paParams: Record<string, unknown> = {
    ReferenceText: expectedText,
    GradingSystem: "HundredMark",
    Granularity: "Phoneme",
    Dimension: "Comprehensive",
    EnableMiscue: true,
    PhonemeAlphabet: "IPA",
  };
  if (language === "en-US") {
    paParams.EnableProsodyAssessment = true;
  }

  const paHeader = btoa(JSON.stringify(paParams));
  const endpoint = `https://${azureResource}.cognitiveservices.azure.com/stt/speech/recognition/conversation/cognitiveservices/v1?language=${language}&format=detailed`;

  const contentType = mimeType.includes("ogg")
    ? "audio/ogg; codecs=opus"
    : "audio/wav; codecs=audio/pcm; samplerate=16000";

  const azResp = await fetch(endpoint, {
    method: "POST",
    headers: {
      "Ocp-Apim-Subscription-Key": azureKey,
      "Content-Type": contentType,
      "Accept": "application/json",
      "Pronunciation-Assessment": paHeader,
    },
    body: audioBytes,
  });

  if (!azResp.ok) {
    const errTxt = await azResp.text();
    return new Response(
      JSON.stringify({
        assessment_status: azResp.status === 429 ? "rate_limited" : "service_error",
        provider: "azure_speech",
        detail: errTxt.slice(0, 300),
      }),
      { status: azResp.status, headers: { "Content-Type": "application/json" } }
    );
  }

  const azJson = await azResp.json();
  const nbest = Array.isArray(azJson.NBest) && azJson.NBest.length > 0 ? azJson.NBest[0] : null;
  const pa = nbest?.PronunciationAssessment ?? null;

  const wordFeedback: Array<Record<string, unknown>> = [];
  const phonemeFeedback: Array<Record<string, unknown>> = [];

  if (Array.isArray(nbest?.Words)) {
    for (const w of nbest.Words) {
      const wPa = w.PronunciationAssessment ?? {};
      wordFeedback.push({
        word: w.Word ?? "",
        accuracy_score: wPa.AccuracyScore ?? null,
        error_type: wPa.ErrorType ?? "None",
      });
      if (Array.isArray(w.Phonemes)) {
        for (const ph of w.Phonemes) {
          phonemeFeedback.push({
            word: w.Word ?? "",
            phoneme: ph.Phoneme ?? "",
            accuracy_score: ph.PronunciationAssessment?.AccuracyScore ?? null,
          });
        }
      }
    }
  }

  const result = {
    provider: "azure_speech",
    assessment_status: pa ? "assessed" : "no_speech_detected",
    recognized_text: azJson.DisplayText ?? nbest?.Display ?? "",
    overall_score: pa?.PronScore ?? null,
    accuracy_score: pa?.AccuracyScore ?? null,
    fluency_score: pa?.FluencyScore ?? null,
    completeness_score: pa?.CompletenessScore ?? null,
    prosody_score: language === "en-US" ? (pa?.ProsodyScore ?? null) : null,
    word_feedback: wordFeedback,
    phoneme_feedback: phonemeFeedback,
  };

  return new Response(JSON.stringify(result), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
});
