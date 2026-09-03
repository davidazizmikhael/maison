-- Vendor identity + contact captured from receipts/nameplates (or well-known
-- retailer knowledge): powers the store icon, tap-to-call and tap-to-email.
alter table public.records add column if not exists vendor_domain text;
alter table public.records add column if not exists vendor_phone text;
alter table public.records add column if not exists vendor_email text;
