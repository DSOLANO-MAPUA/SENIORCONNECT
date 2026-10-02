# SeniorConnect

A community events platform for senior citizens (ITS 122). Attendees browse events and announcements and register for events; staff and admins manage events, announcements and users.

- **Frontend:** PHP pages + vanilla JavaScript (PHP sessions guard every protected page)
- **Backend:** Flask REST API (JWT, role checks, hashed 4-digit PINs, login lockout)
- **Database:** MySQL / MariaDB (9 tables with foreign keys, see `database/schema.sql`)

```
Browser ──► nginx ──► PHP pages (login.php, index.php, ...)
              └─/api─► Flask (gunicorn) ──► MySQL
```

## Run locally

Requirements: Python 3.10+, PHP 8+, MySQL/MariaDB.

```bash
# 1. database
mysql -u root -p < database/schema.sql
mysql -u root -p < database/demo_data.sql      # optional test accounts (PIN 1234)

# 2. Python
python -m venv venv && source venv/bin/activate      # Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env                                  # then edit the values
python app.py                                         # Flask on :5000

# 3. PHP (second terminal). dev-router.php forwards /api to Flask
php -S localhost:8000 dev-router.php
```

Open http://localhost:8000/login.php

## Deploy

| Where | Guide |
|---|---|
| **Railway** (from this GitHub repo) | below |
| Your own Ubuntu server (nginx + systemd) | [`docs/DEPLOY-VPS.md`](docs/DEPLOY-VPS.md) |

### Railway

1. Push this repo to GitHub (keep it **private**).
2. On railway.com: **New Project → Deploy from GitHub repo** → pick the repo. Railway builds the `Dockerfile` automatically.
3. In the same project: **New → Database → MySQL**.
4. Open the web service → **Variables** and add:

   | Variable | Value |
   |---|---|
   | `DATABASE_URL` | `${{MySQL.MYSQL_URL}}` (use the name of your MySQL service) |
   | `SECRET_KEY` | random string (see below) |
   | `JWT_SECRET_KEY` | a different random string |
   | `ADMIN_NAME` | your admin's name |
   | `ADMIN_PHONE` | your admin's phone |
   | `ADMIN_PIN` | 4 digits |

   Generate secrets: `python3 -c "import secrets; print(secrets.token_hex(32))"`
5. Web service → **Settings → Networking → Generate Domain**, then open `https://<your-domain>/login.php`.
6. On first start the app creates the tables and the admin account automatically. After you can log in, **delete `ADMIN_PIN`** from the variables.

## Security notes

- Never commit `.env`; it is git-ignored. Real secrets live in Railway variables.
- PINs are stored hashed. 3 wrong attempts lock the account for 1 minute (`LOCK_MINUTES` in `app.py`).
- `database/demo_data.sql` is for local testing only. Don't load it on a public site.
- A 4-digit PIN is weak by nature; consider rate limiting at the proxy for a real deployment.

## Project layout

```
app.py              Flask API (models, routes, auth)
init_db.py          creates missing tables (+ optional first admin) on start
create_admin.py     interactive admin creator for servers
auth.php            PHP session helpers (required by every page)
*.php / *.js        pages and their scripts
database/           schema.sql, demo_data.sql
docker/, Dockerfile single-container setup (nginx + PHP-FPM + gunicorn)
dev-router.php      local dev helper (proxies /api to Flask)
```
