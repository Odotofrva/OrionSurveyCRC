# Clean Rite Center — GitHub Pages + Supabase

## Setup
1. Create a Supabase project. Open SQL Editor and run `setup.sql`.
2. In Supabase **Authentication > Users**, create/invite your manager account (email/password). Copy the user's UUID. In SQL Editor run:
   `insert into public.survey_admins(user_id) values ('YOUR-AUTH-USER-UUID');`
   This step must be performed in SQL Editor, not in the browser.
3. Open **Project Settings > API** (or **Connect**) and copy the Project URL and **publishable** key into `config.js`. Never put a `service_role` or secret key in frontend files.
4. Upload `index.html`, `dashboard.html`, and `config.js` to the root of your GitHub Pages repository. Keep `setup.sql` and this README off the public site if you prefer (SQL has no secrets).
5. Visit your GitHub Pages URL, submit a test survey, then visit `/dashboard.html` and log in. Approve the survey; refresh the public site to see it.
6. Disable open sign-ups in Supabase Authentication if you don't want users creating accounts. Only users listed in `survey_admins` can access the management data even if sign-ups are enabled.

## Security and privacy
- Public visitors can submit reviews but cannot read private submissions. Only approved reviews are displayed publicly, **without customer names**.
- The manager dashboard requires an authenticated account explicitly allowlisted in `survey_admins`.
- Anonymous users can still spam submissions. For production, add CAPTCHA with server-side verification through a Supabase Edge Function, and rate limiting. Client-side CAPTCHA alone is insufficient.
- The database stores names if supplied, ratings, feedback, language, and timestamps. Inform customers that feedback may be published anonymously after approval.
- The public statistics summarize **approved reviews only**; the dashboard summarizes all submissions.
- Old localStorage reviews are **not** automatically imported.
- Never commit your database password, Supabase secret/service_role keys, or personal manager credentials.
- For stronger controls on data integrity, consider restricting update privileges to the `status` column through a dedicated RPC, rather than general row updates. Current dashboard only updates `status`.
