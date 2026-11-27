// Supabase Edge Function: speech-recognize
// Dedicated Speech-to-Text (STT) proxy strictly separated from Pronunciation Assessment.
// Returns recognized text only — NEVER computes fake pronunciation scores.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const MAX_AUDIO_BYTES = 2 * 1024 * 1024;

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
        status: "provider_unavailable",
        recognized_text: "",
        provider: "azure_stt",
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
  const language = body.language === "en-GB" ? "en-GB" : "en-US";
  if (!audioBase64) {
    return new Response(JSON.stringify({ error: "audio_base64 is required" }), { status: 400 });
  }

  const binaryStr = atob(audioBase64);
  if (binaryStr.length > MAX_AUDIO_BYTES) {
    return new Response(JSON.stringify({ error: "Audio exceeds 2MB limit" }), { status: 413 });
  }
  const audioBytes = new Uint8Array(binaryStr.length);
  for (let i = 0; i < binaryStr.length; i++) {
    audioBytes[i] = binaryStr.charCodeAt(i);
  }

  const endpoint = `https://${azureResource}.cognitiveservices.azure.com/stt/speech/recognition/conversation/cognitiveservices/v1?language=${language}&format=simple`;
  const azResp = await fetch(endpoint, {
    method: "POST",
    headers: {
      "Ocp-Apim-Subscription-Key": azureKey,
      "Content-Type": "audio/wav; codecs=audio/pcm; samplerate=16000",
      "Accept": "application/json",
    },
    body: audioBytes,
  });

  if (!azResp.ok) {
    return new Response(JSON.stringify({ status: "service_error", recognized_text: "", provider: "azure_stt" }), {
      status: azResp.status,
      headers: { "Content-Type": "application/json" },
    });
  }

  const azJson = await azResp.json();
  return new Response(
    JSON.stringify({
      provider: "azure_stt",
      recognized_text: azJson.DisplayText ?? "",
      recognition_status: azJson.RecognitionStatus ?? "Unknown",
    }),
    { status: 200, headers: { "Content-Type": "application/json" } }
  );
});
