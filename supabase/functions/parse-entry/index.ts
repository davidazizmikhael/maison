// Maison AI parsing endpoint.
// POST { mode: 'nameplate' | 'receipt' | 'note', text?, image_base64?, media_type? }
// -> { record: {...}, reminders: [...] } structured by Claude.
//
// Deploy:  supabase functions deploy parse-entry
// Secrets: supabase secrets set ANTHROPIC_API_KEY=sk-ant-...

import Anthropic from "npm:@anthropic-ai/sdk";
import { z } from "npm:zod@3";
import { zodOutputFormat } from "npm:@anthropic-ai/sdk/helpers/zod";

const MODEL = Deno.env.get("PARSE_MODEL") ?? "claude-opus-5";

const ParsedEntry = z.object({
  kind: z.enum(["appliance", "receipt", "service"]),
  title: z.string(),
  subtitle: z.string(),
  room: z.string(),
  cost: z.number().nullable(),
  vendor: z.string().nullable(),
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
        cost: null, vendor: null, model_serial: "S/N 5919C04532",
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
        cost: 1699.99, vendor: "Canadian Tire", model_serial: null,
        warranty_until: plusDays(3 * 365), return_by: plusDays(90), confidence: "low",
      },
      reminders: [],
    },
    note: {
      record: {
        kind: "service", title: text?.slice(0, 60) || "Home repair",
        subtitle: "Typed note (demo parse)", room: "Home",
        cost: Number(text?.match(/\$?\s?(\d[\d,]*(?:\.\d{1,2})?)/)?.[1]?.replaceAll(",", "")) || null,
        vendor: null, model_serial: null,
        warranty_until: null, return_by: null, confidence: "low",
      },
      reminders: [],
    },
  } as const;
  return base[(mode as keyof typeof base)] ?? base.note;
}

function instructionFor(mode: string, today: string): string {
  const base =
    `You extract structured home-maintenance records for the Maison app. Today is ${today}. ` +
    `Return dates as ISO (YYYY-MM-DD). Use null when a field is not present — never invent values. ` +
    `Set confidence to "low" when the input is blurry or ambiguous. ` +
    `Suggest 0-2 maintenance reminders only when the item genuinely has a recurring task or deadline.`;
  switch (mode) {
    case "nameplate":
      return `${base} The image is an appliance nameplate / rating plate. ` +
        `Extract the brand and model into title (e.g. "Furnace — Lennox ML296V"), the serial into model_serial, ` +
        `kind is "appliance". Infer the room from the appliance type (furnace/water heater → Basement, etc.).`;
    case "receipt":
      return `${base} The image is a purchase receipt or contractor invoice. ` +
        `Extract the main item into title, total price into cost, the store/contractor into vendor. ` +
        `kind is "receipt" for store purchases or "service" for contractor work. ` +
        `Estimate warranty_until from any stated warranty terms and return_by from the store's return policy if printed.`;
    default:
      return `${base} The input is a free-text note the homeowner typed. kind is usually "service". ` +
        `Extract what was done into title, parts/details into subtitle, price into cost, who did it into vendor.`;
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

    const apiKey = Deno.env.get("ANTHROPIC_API_KEY");
    if (!apiKey) {
      const demo = fallbackParse(mode, text, new Date());
      return new Response(JSON.stringify({ ...demo, demo: true }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const client = new Anthropic({ apiKey });

    const today = new Date().toISOString().slice(0, 10);
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
