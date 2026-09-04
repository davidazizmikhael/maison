// Maison AI parsing endpoint.
// POST { mode: 'nameplate' | 'receipt' | 'note', text?, image_base64?, media_type? }
// -> { record: {...}, reminders: [...] } structured by Claude.
//
// Deploy:  supabase functions deploy parse-entry
// Secrets: supabase secrets set ANTHROPIC_API_KEY=sk-ant-...

import { createClient } from "npm:@supabase/supabase-js@2";
import Anthropic from "npm:@anthropic-ai/sdk";
import { z } from "npm:zod@4";
import { zodOutputFormat } from "npm:@anthropic-ai/sdk/helpers/zod";

const MODEL = Deno.env.get("PARSE_MODEL") ?? "claude-opus-5";
const GEMINI_MODEL = Deno.env.get("GEMINI_MODEL") ?? "gemini-2.5-flash";

const ParsedEntry = z.object({
  kind: z.enum(["appliance", "receipt", "service"]),
  title: z.string(),
  subtitle: z.string(),
  room: z.string(),
  cost: z.number().nullable(),
  vendor: z.string().nullable(),
  vendor_domain: z.string().nullable(), // primary web domain, e.g. "canadiantire.ca"
  vendor_phone: z.string().nullable(),
  vendor_email: z.string().nullable(),
  model_serial: z.string().nullable(),
  warranty_until: z.string().nullable(), // ISO date
  return_by: z.string().nullable(), // ISO date
  confidence: z.enum(["high", "medium", "low"]),
  reminders: z.array(
    z.object({
      title: z.string(),
      detail: z.string(),
      due_on: z.string(), // ISO date
      seasonal: z.boolean(),
    }),
  ),
});

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// Deterministic stand-in used while no ANTHROPIC_API_KEY secret is set, so the
// full cloud pipeline (auth → function → app) works before the AI is enabled.
// Flip on the real AI later with: supabase secrets set ANTHROPIC_API_KEY=...
function fallbackParse(mode: string, text: string | undefined, today: Date) {
  const iso = (d: Date) => d.toISOString().slice(0, 10);
  const plusDays = (n: number) => iso(new Date(today.getTime() + n * 86400000));
  const base = {
    nameplate: {
      record: {
        kind: "appliance", title: "Furnace — Lennox ML296V",
        subtitle: "High-efficiency gas furnace (demo parse)", room: "Basement",
        cost: null, vendor: null, vendor_domain: "lennox.com",
        vendor_phone: "1-800-953-6669", vendor_email: null, model_serial: "S/N 5919C04532",
        warranty_until: plusDays(3 * 365), return_by: null, confidence: "low",
      },
      reminders: [{
        title: "Replace furnace filter", detail: "Every 3 months",
        due_on: plusDays(90), seasonal: true,
      }],
    },
    receipt: {
      record: {
        kind: "receipt", title: "Snow blower — Toro Power Max 826",
        subtitle: "From receipt (demo parse)", room: "Garage",
        cost: 1699.99, vendor: "Canadian Tire", vendor_domain: "canadiantire.ca",
        vendor_phone: "1-800-387-8803", vendor_email: null, model_serial: null,
        warranty_until: plusDays(3 * 365), return_by: plusDays(90), confidence: "low",
      },
      reminders: [],
    },
    note: {
      record: {
        kind: "service", title: text?.slice(0, 60) || "Home repair",
        subtitle: "Typed note (demo parse)", room: "Home",
        cost: Number(text?.match(/\$?\s?(\d[\d,]*(?:\.\d{1,2})?)/)?.[1]?.replaceAll(",", "")) || null,
        vendor: null, vendor_domain: null, vendor_phone: null, vendor_email: null,
        model_serial: null, warranty_until: null, return_by: null, confidence: "low",
      },
      reminders: [],
    },
  } as const;
  if (mode === "photo") return base.nameplate;
  return base[(mode as keyof typeof base)] ?? base.note;
}

// Gemini's responseSchema is an OpenAPI subset — mirror of ParsedEntry above.
const geminiSchema = {
  type: "OBJECT",
  properties: {
    kind: { type: "STRING", enum: ["appliance", "receipt", "service"] },
    title: { type: "STRING" },
    subtitle: { type: "STRING" },
    room: { type: "STRING" },
    cost: { type: "NUMBER", nullable: true },
    vendor: { type: "STRING", nullable: true },
    vendor_domain: { type: "STRING", nullable: true },
    vendor_phone: { type: "STRING", nullable: true },
    vendor_email: { type: "STRING", nullable: true },
    model_serial: { type: "STRING", nullable: true },
    warranty_until: { type: "STRING", nullable: true },
    return_by: { type: "STRING", nullable: true },
    confidence: { type: "STRING", enum: ["high", "medium", "low"] },
    reminders: {
      type: "ARRAY",
      items: {
        type: "OBJECT",
        properties: {
          title: { type: "STRING" },
          detail: { type: "STRING" },
          due_on: { type: "STRING" },
          seasonal: { type: "BOOLEAN" },
        },
        required: ["title", "detail", "due_on", "seasonal"],
      },
    },
  },
  required: ["kind", "title", "subtitle", "room", "cost", "vendor", "vendor_domain",
    "vendor_phone", "vendor_email", "model_serial", "warranty_until", "return_by",
    "confidence", "reminders"],
};

async function parseWithGemini(
  apiKey: string,
  instruction: string,
  text: string | undefined,
  imageBase64: string | undefined,
  mediaType: string,
): Promise<z.infer<typeof ParsedEntry>> {
  const parts: Record<string, unknown>[] = [];
  if (imageBase64) {
    parts.push({ inline_data: { mime_type: mediaType, data: imageBase64 } });
  }
  parts.push({
    text: text && !imageBase64
      ? `Note from the homeowner: "${text}"`
      : "Extract the record from this image.",
  });
  const request = {
    method: "POST",
    headers: { "x-goog-api-key": apiKey, "Content-Type": "application/json" },
    body: JSON.stringify({
      systemInstruction: { parts: [{ text: instruction }] },
      contents: [{ role: "user", parts }],
      generationConfig: {
        responseMimeType: "application/json",
        responseSchema: geminiSchema,
      },
    }),
  };
  const url =
    `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent`;
  // Free-tier demand spikes (503) are frequent but short — back off and retry
  // a few times before giving up; the app's card offers a manual retry after.
  let res = await fetch(url, request);
  for (const delayMs of [1500, 3000, 5000]) {
    if (res.status !== 503) break;
    await new Promise((r) => setTimeout(r, delayMs));
    res = await fetch(url, request);
  }
  if (!res.ok) {
    const body = await res.text();
    console.error("gemini error", res.status, body.slice(0, 500));
    throw { gemini: true, status: res.status };
  }
  const data = await res.json();
  const raw = data?.candidates?.[0]?.content?.parts?.[0]?.text;
  if (!raw) throw { gemini: true, status: 502 };
  const validated = ParsedEntry.safeParse(JSON.parse(raw));
  if (!validated.success) {
    console.error("gemini schema mismatch", validated.error.message.slice(0, 300));
    throw { gemini: true, status: 502 };
  }
  return validated.data;
}

function instructionFor(mode: string, today: string): string {
  const base =
    `You extract structured home-maintenance records for the Maison app. Today is ${today}. ` +
    `Return dates as ISO (YYYY-MM-DD). Use null when a field is not present — never invent values. ` +
    `Set confidence to "low" when the input is blurry or ambiguous. ` +
    `Suggest 0-2 maintenance reminders only when the item genuinely has a recurring task or deadline. ` +
    `Vendor contact: if a phone number, email or website is printed on the input, extract it into ` +
    `vendor_phone / vendor_email / vendor_domain (domain only, e.g. "canadiantire.ca"). For a well-known ` +
    `retailer or manufacturer you may fill vendor_domain from knowledge, and vendor_phone ONLY when you are ` +
    `certain of its widely published customer-service number — NEVER guess digits or invent an email; use null.`;
  const nameplateRules =
    `Nameplate / rating plate: extract the brand and model into title (e.g. "Furnace — Lennox ML296V"), ` +
    `the serial into model_serial, kind is "appliance". Infer the room from the appliance type ` +
    `(furnace/water heater → Basement, etc.). Estimate warranty_until from typical manufacturer terms ` +
    `only when the label states them; otherwise null.`;
  const receiptRules =
    `Receipt / invoice — ANY retail purchase counts, not just home items: clothing, shoes, electronics, gifts. ` +
    `Extract the main item into title, total price into cost, the store/contractor into vendor. ` +
    `kind is "receipt" for store purchases or "service" for contractor work. For non-home items use room "Home". ` +
    `Estimate warranty_until from any stated warranty terms. For return_by: use the return policy printed on the ` +
    `receipt; when none is printed but the retailer's standard policy is widely known (e.g. 30 days), use it and ` +
    `set confidence "low"; otherwise null. When return_by is set, ALWAYS include a reminder titled like ` +
    `"Return window closes" due 3 days before return_by so the buyer can still act on it.`;
  switch (mode) {
    case "photo":
      return `${base} The image is a photo the homeowner just took. FIRST decide what it shows: an appliance ` +
        `nameplate/rating plate, a purchase receipt or invoice, or something else (a product box, a manual cover, ` +
        `a repair in progress). Then apply the matching rules. ${nameplateRules} ${receiptRules} ` +
        `If it is neither, describe the item as best you can with kind "service" or "appliance" and confidence "low".`;
    case "nameplate":
      return `${base} The image is an appliance nameplate / rating plate. ` +
        `Extract the brand and model into title (e.g. "Furnace — Lennox ML296V"), the serial into model_serial, ` +
        `kind is "appliance". Infer the room from the appliance type (furnace/water heater → Basement, etc.).`;
    case "receipt":
      return `${base} The image is a purchase receipt or contractor invoice — ANY retail purchase counts, ` +
        `not just home items: clothing, shoes, electronics, gifts. ` +
        `Extract the main item into title, total price into cost, the store/contractor into vendor. ` +
        `kind is "receipt" for store purchases or "service" for contractor work. ` +
        `For non-home items use room "Home". ` +
        `Estimate warranty_until from any stated warranty terms. For return_by: use the return policy printed ` +
        `on the receipt; when none is printed but the retailer's standard policy is widely known (e.g. 30 days), ` +
        `use it and set confidence "low"; otherwise null. When return_by is set, ALWAYS include a reminder ` +
        `titled like "Return window closes" due 3 days before return_by so the buyer can still act on it.`;
    default:
      return `${base} The input is a free-text note the homeowner typed. kind is usually "service". ` +
        `Extract what was done into title, parts/details into subtitle, price into cost, who did it into vendor. ` +
        `If the note mentions a deadline, future date, or follow-up intent ("due Oct 15", "remind me next month", ` +
        `"needs another look in the spring"), create a reminder with that due_on date resolved against today's date.`;
  }
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  try {
    const { mode, text, image_base64, media_type } = await req.json();
    if (!mode || (!text && !image_base64)) {
      return new Response(
        JSON.stringify({ error: "mode plus text or image_base64 required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // Who is calling? Resolve from the JWT — and cap parses per user per day
    // so a single client can't run up the AI bill.
    const supaUrl = Deno.env.get("SUPABASE_URL")!;
    const asCaller = createClient(supaUrl, Deno.env.get("SUPABASE_ANON_KEY")!, {
      global: { headers: { Authorization: req.headers.get("Authorization") ?? "" } },
    });
    const { data: userData } = await asCaller.auth.getUser();
    if (!userData?.user) {
      return new Response(JSON.stringify({ error: "not authenticated" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }
    const DAILY_LIMIT = 50;
    const admin = createClient(supaUrl, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
    const { data: usedToday, error: usageError } = await admin.rpc("increment_parse_usage", {
      uid: userData.user.id,
      on_day: new Date().toISOString().slice(0, 10),
    });
    if (!usageError && typeof usedToday === "number" && usedToday > DAILY_LIMIT) {
      return new Response(JSON.stringify({ error: "rate_limited" }), {
        status: 429,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Provider: Gemini when its key exists (free tier — good for demos),
    // Anthropic otherwise; deterministic fallback when neither is set.
    // Override with PARSE_PROVIDER=gemini|anthropic.
    const geminiKey = Deno.env.get("GEMINI_API_KEY");
    const anthropicKey = Deno.env.get("ANTHROPIC_API_KEY");
    const provider = Deno.env.get("PARSE_PROVIDER") ??
      (geminiKey ? "gemini" : anthropicKey ? "anthropic" : "none");
    const today = new Date().toISOString().slice(0, 10);

    if (provider === "none" || (provider === "gemini" && !geminiKey) ||
        (provider === "anthropic" && !anthropicKey)) {
      const demo = fallbackParse(mode, text, new Date());
      return new Response(JSON.stringify({ ...demo, demo: true }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (provider === "gemini") {
      try {
        const parsed = await parseWithGemini(
          geminiKey!, instructionFor(mode, today), text, image_base64,
          media_type ?? "image/jpeg");
        const { reminders, ...record } = parsed;
        return new Response(JSON.stringify({ record, reminders }), {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      } catch (err) {
        const status = (err as { status?: number }).status ?? 500;
        // Free-tier RPM/RPD limits surface as 429 — the app shows the
        // friendly rate message rather than a raw error.
        return new Response(
          JSON.stringify({ error: status === 429 ? "rate_limited" : `AI service error (${status})` }),
          { status: status === 429 ? 429 : 502,
            headers: { ...corsHeaders, "Content-Type": "application/json" } },
        );
      }
    }

    const client = new Anthropic({ apiKey: anthropicKey! });
    const content: Anthropic.ContentBlockParam[] = [];
    if (image_base64) {
      content.push({
        type: "image",
        source: {
          type: "base64",
          media_type: media_type ?? "image/jpeg",
          data: image_base64,
        },
      });
    }
    content.push({
      type: "text",
      text: text && !image_base64 ? `Note from the homeowner: "${text}"` : "Extract the record from this image.",
    });

    const response = await client.messages.parse({
      model: MODEL,
      max_tokens: 2048,
      system: instructionFor(mode, today),
      messages: [{ role: "user", content }],
      output_config: { format: zodOutputFormat(ParsedEntry) },
    });

    if (response.stop_reason === "refusal" || !response.parsed_output) {
      return new Response(
        JSON.stringify({ error: "Could not parse this input — try a clearer photo." }),
        { status: 422, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const { reminders, ...record } = response.parsed_output;
    return new Response(JSON.stringify({ record, reminders }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err) {
    if (err instanceof Anthropic.APIError) {
      console.error("anthropic error", err.status, err.message); // server logs only
      return new Response(
        JSON.stringify({ error: `AI service error (${err.status})` }),
        { status: 502, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
