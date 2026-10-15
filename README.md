# grant-control-survey

Each participant evaluates five random active cards from `cards/cards.pptx`. GitHub Actions renders the slides and publishes the website. `card_overrides.json` excludes templates, reference cards, and answer slides.

## Response collection

Both surveys submit to Cloudflare Workers and save to the same private Cloudflare D1 database, **survey-responses**, in the **responses** table. The `game` column identifies each survey. Responses are not written to GitHub or offered for download to participants. Submission is confirmed only after the database accepts it. Retrying the same respondent ID and card ID does not create duplicate rows.

To view responses, sign in to Cloudflare, open **Storage & databases → D1 → survey-responses → Console**, and run:

```sql
SELECT * FROM responses ORDER BY received_at DESC;
```

To download all responses as a CSV, run `python tools/export_responses.py` after Wrangler login. The file is saved to `~/Downloads/survey-responses.csv`. Both surveys are included.

To export a database backup using an authenticated Wrangler installation:

```sh
npx wrangler d1 export survey-responses --remote --output /tmp/survey-responses.sql -c worker/wrangler.toml
```

## Deploy the submission service

Use the Workers Free plan. The existing `worker/wrangler.toml` binds the shared database.

```sh
npx wrangler login
npx wrangler deploy -c worker/wrangler.toml
```

When changing cards, update `worker/allowed-cards.json` from the active card IDs, titles, and options in the generated `cards.json`, then redeploy the Worker.

Existing browser-only preview responses are preserved on their originating devices; they have not been imported into the central database. The old `data/responses.csv` is an unused header-only file.

## Grant review questions (version 2)

The card form asks whether the prompt is properly formatted (Yes/No), whether the grant is relevant to the field (Yes/No), a 1–5 context clarity rating, optional technical issues, and optional writing issues. Overall game questions remain. New responses have `survey_version=2`, `properly_formatted`, `field_relevant`, `technical_issues`, and `writing_issues`. `clarity` holds context clarity. Removed gameplay `interest` and `comprehension` are NULL for version 2. Prior responses are preserved.

Each submission saves five rows, one per distinct randomly assigned card. All five writes commit together. Earlier one-card responses are preserved.
