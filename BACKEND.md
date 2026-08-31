# Maison backend (Supabase)

> **Status (Aug 31, 2026):** project `YOUR_PROJECT_REF` (ca-central-1) is live —
> schema pushed, anonymous sign-in enabled, `parse-entry` deployed. No
> model provider key is set yet, so the function returns deterministic demo parses
> (`"demo": true`). Setting the secret + redeploying flips on the real AI; no
> app changes needed.

The backend lives in `supabase/`:

- `migrations/20260831000001_init.sql` — schema (`homes`, `records`, `reminders`),
  row-level security (every row visible only to its owner), and a private
  `captures` storage bucket for nameplate/receipt photos.
- `functions/parse-entry/` — the AI endpoint. Takes a photo (base64) or a text
  note, calls the configured language model, returns a structured record + suggested reminders.

The Flutter app talks to it through `lib/services/backend.dart`. With no
credentials configured the app runs in **demo mode** (in-memory mock, exactly
what you've been testing). With credentials it switches to the real backend.

## One-time setup (needs your accounts — ~15 minutes)

1. **Create the Supabase project** (free tier is fine to start):
   sign up at https://supabase.com → New project → pick the `ca-central-1`
   (Montréal) region.

2. **Link this repo to it and push the schema:**

   ```bash
   supabase login
   ```

   ```bash
   supabase link --project-ref YOUR_PROJECT_REF
   ```

   ```bash
   supabase db push
   ```

3. **Enable anonymous sign-in** (Dashboard → Authentication → Providers →
   Anonymous) — v1 uses frictionless anonymous auth, upgradeable to
   Apple/email later without losing data.

4. **Set the AI provider key and deploy the function** (get a key from
   the provider's console):

   ```bash
   supabase secrets set ANTHROPIC_API_KEY=sk-ant-your-key
   ```

   ```bash
   supabase functions deploy parse-entry
   ```

5. **Run the app against the real backend:**

   ```bash
   flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
   ```

## Local development (no cloud project needed)

With Docker running:

```bash
supabase start
```

```bash
supabase functions serve parse-entry --env-file <(echo ANTHROPIC_API_KEY=sk-ant-your-key)
```

`supabase start` prints a local URL + anon key you can pass as the
`--dart-define`s above.

## Cost notes

- The edge function defaults to the paid provider's most capable model for maximum extraction quality.
  Once you have real test photos, benchmark cheaper models by setting the
  `PARSE_MODEL` secret
  — for simple label OCR it may be indistinguishable and ~5x cheaper per scan.
- Supabase free tier covers development and early beta comfortably
  (500MB database, 1GB storage, 500K edge function calls/month).
