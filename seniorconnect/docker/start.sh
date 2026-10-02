#!/bin/sh
set -e
cd /app

: "${PORT:=8080}"
export PORT

# Fail early with a clear message if required settings are missing.
for v in SECRET_KEY JWT_SECRET_KEY; do
  eval "val=\${$v}"
  [ -n "$val" ] || { echo "ERROR: environment variable $v is not set"; exit 1; }
done
[ -n "$DATABASE_URL" ] || [ -n "$DB_NAME" ] || { echo "ERROR: set DATABASE_URL (or DB_* variables)"; exit 1; }

# Create missing tables (+ first admin if ADMIN_* variables are set). Retry while the DB wakes up.
i=0
until python init_db.py; do
  i=$((i+1))
  [ "$i" -ge 15 ] && { echo "ERROR: database not reachable"; exit 1; }
  echo "Waiting for database ($i/15)..."; sleep 4
done

# Fill ${PORT} into the nginx config (only that variable; $uri etc. stay untouched).
envsubst '${PORT}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf
nginx -t

exec supervisord -c /etc/supervisord.conf
