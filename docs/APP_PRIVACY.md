# App Store / Play Store privacy declarations

Privacy policy URL (both stores): **https://davidazizmikhael.github.io/legal/maison/**

## Apple App Privacy questionnaire (App Store Connect → App Privacy)

Answer "Yes, we collect data from this app", then declare exactly these:

| Data type | Collected? | Linked to user? | Used for tracking? | Purposes |
|---|---|---|---|---|
| Contact Info → Email Address | Yes (only when the user links Sign in with Apple) | Yes | No | App Functionality |
| User Content → Photos or Videos | Yes (nameplate/receipt captures) | Yes | No | App Functionality |
| User Content → Other User Content | Yes (notes, home profile, records, reminders) | Yes | No | App Functionality |
| Identifiers → User ID | Yes (anonymous Supabase account id) | Yes | No | App Functionality |
| Diagnostics → Crash Data | Yes (only when SENTRY_DSN is configured in the build) | No | No | App Functionality |

Everything else (location, contacts, browsing history, purchases, usage data,
advertising data…): **Not collected.** "Used for tracking" is **No** for every
type — there is no ads SDK and no cross-app identifier.

Notes for review:
- Photos are processed by a third-party AI model API solely to extract the record;
  state this in the App Review notes if asked about third-party AI.
- In-app account deletion: Account sheet → "Delete account & data"
  (guideline 5.1.1(v)) — wipes auth user, rows, and storage.

## Google Play Data safety form

- Data collected: Email (optional, account linking), Photos, Other user content,
  User IDs, Crash logs.
- All encrypted in transit: Yes. Deletion mechanism: Yes (in-app).
- Data shared with third parties: No (processors — Supabase hosting, AI
  parsing — act on our behalf; Play's definition of "sharing" excludes service
  providers).
- No ads. No tracking.
