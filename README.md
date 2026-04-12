# Miltydraft generator

[Visit the app here](https://milty.shenanigans.be/).

An expanded version of miltydraft.com, with saving/sharing drafts across sessions.

## Getting started

Clone the repo:

```
git clone git@github.com:shenanigans-be/miltydraft.git
cd miltydraft
```

### Option A — Nix (recommended)

Requires [Nix](https://nixos.org/download/) with flakes enabled.

```bash
nix develop          # enters the dev shell; creates .env and tmp/ automatically
composer install     # install PHP dependencies
serve                # start the dev server on http://localhost:8080
```

Edit `.env` before running:

```
URL="http://localhost:8080/"
DEV_PORT="8080"
STORAGE="local"
STORAGE_PATH="data/drafts"
```

`serve` reads `DEV_PORT` from `.env` (default `8080`). You can also override it once with `serve 9000`.

### Option B — Docker

Requires [Docker](https://docs.docker.com/get-started/).

```bash
docker compose up -d --build
docker compose exec app composer install
```

Go to `https://milty.localhost` (or `http://localhost`).
Your browser will warn about the self-signed certificate — you can import it:

```bash
docker compose exec app cat /home/app/.local/share/caddy/pki/authorities/local/root.crt > caddy-cert.crt
```

Add `127.0.0.1 milty.localhost` to `/etc/hosts` to use the custom domain.

---

## Accessing over Tailscale

Any machine on your Tailscale network can reach the dev server if it is bound to `0.0.0.0` (which `serve` does by default).

1. Find your machine's Tailscale IP: `tailscale ip -4` (e.g. `100.x.y.z`)
   or use your MagicDNS hostname (e.g. `mymachine.tail1234.ts.net`).
2. Set `URL` in `.env` to that address **with trailing slash**:
   ```
   URL="http://100.x.y.z:8080/"
   ```
3. Run `serve` and open `http://100.x.y.z:8080` from any Tailscale device.

The `URL` value is used to build links inside the app (e.g. draft share URLs and email notifications), so it must match the address players will use to open the app.

---

## Email notifications

When it's a player's turn to pick, the app can email them a link to the draft. Emails are optional per-player and entered on the draft creation form.

To enable, add SMTP credentials to `.env`:

```
MAIL_HOST="smtp.example.com"
MAIL_PORT="587"
MAIL_USERNAME="you@example.com"
MAIL_PASSWORD="your-password"
MAIL_FROM_ADDRESS="you@example.com"
MAIL_FROM_NAME="MiltyDraft"
MAIL_ENCRYPTION="tls"   # or "ssl" for port 465
```

Leave `MAIL_HOST` blank (the default) to disable email entirely.

**Local testing with Mailpit** — Mailpit is a local SMTP sink that captures outgoing mail without sending it:

```bash
# run Mailpit (Docker)
docker run -d -p 1025:1025 -p 8025:8025 axllent/mailpit

# .env settings
MAIL_HOST="localhost"
MAIL_PORT="1025"
MAIL_USERNAME=""
MAIL_PASSWORD=""
MAIL_FROM_ADDRESS="dev@localhost"
MAIL_ENCRYPTION="tls"
```

Open `http://localhost:8025` to view captured emails.

---

## Libraries and Dependencies

Frontend runs on vanilla JS/jQuery and the backend is vanilla PHP. No build system or compilation step required beyond `composer install`.

External dependencies are kept to a minimum by design.

## App flow

1. Players visit the app and choose draft options including optional email addresses.
2. A JSON config file is created (locally or on S3, depending on `.env`) with a unique ID.
3. The Draft ID is the Draft URL: `APP_URL/d/{draft-id}`.
4. Players make draft choices in snake-draft order. If an email was provided, the next player is notified by email when it's their turn.
