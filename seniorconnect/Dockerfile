# SeniorConnect: nginx + PHP-FPM + Flask (gunicorn) in ONE container.
# Works on Railway (and any Docker host). nginx listens on $PORT and forwards /api to Flask.
FROM python:3.12-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
        nginx php-fpm gettext-base supervisor ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . /app

# nginx / php-fpm / supervisor config
RUN rm -f /etc/nginx/sites-enabled/default /etc/nginx/conf.d/default.conf \
 && cp docker/nginx.conf.template /etc/nginx/nginx.conf.template \
 && cp docker/php-fpm-pool.conf /etc/php/8.2/fpm/pool.d/www.conf \
 && cp docker/supervisord.conf /etc/supervisord.conf \
 && mkdir -p /run/php /var/lib/php/sessions \
 && chmod 1733 /var/lib/php/sessions \
 && chmod +x docker/start.sh

# Railway injects PORT; 8080 is only the fallback for local `docker run`.
ENV PORT=8080
EXPOSE 8080

CMD ["/app/docker/start.sh"]
