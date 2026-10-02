# Deploying SeniorConnect (PHP + Flask on one Ubuntu server)

nginx serves the PHP pages and forwards `/api/...` to Flask (gunicorn).
Visitors only ever talk to one domain; Flask is never exposed directly.

## 1. Server packages (Ubuntu 22.04 / 24.04)
```bash
sudo apt update
sudo apt install -y nginx php-fpm mariadb-server python3-venv python3-pip certbot python3-certbot-nginx
```

## 2. Database
```bash
sudo mysql_secure_installation
sudo mysql < database/schema.sql          # creates ITS122P_Database + tables
sudo mysql -e "CREATE USER 'seniorconnect'@'localhost' IDENTIFIED BY 'A-STRONG-PASSWORD';
               GRANT ALL ON ITS122P_Database.* TO 'seniorconnect'@'localhost'; FLUSH PRIVILEGES;"
```
Do NOT load `database/demo_data.sql` on a public site. (schema.sql drops tables: never re-run it on live data.)

## 3. Copy the project and install Python packages
```bash
sudo mkdir -p /var/www/seniorconnect
sudo cp -r ./* /var/www/seniorconnect/        # run from the project folder
cd /var/www/seniorconnect
sudo python3 -m venv venv
sudo venv/bin/pip install -r requirements.txt
sudo chown -R www-data:www-data /var/www/seniorconnect
```

## 4. Secrets (kept OUTSIDE the web folder)
```bash
python3 -c "import secrets; print(secrets.token_hex(32))"   # run twice: SECRET_KEY and JWT_SECRET_KEY
sudo cp .env.example /etc/seniorconnect.env
sudo nano /etc/seniorconnect.env      # fill in real values (DB_PASSWORD = the one from step 2)
sudo chmod 640 /etc/seniorconnect.env && sudo chown root:www-data /etc/seniorconnect.env
```

## 5. Create the first admin
```bash
cd /var/www/seniorconnect
sudo -u www-data bash -c 'set -a; . /etc/seniorconnect.env; set +a; venv/bin/python create_admin.py'
```

## 6. Start Flask as a service
```bash
sudo cp deploy/seniorconnect.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now seniorconnect
curl http://127.0.0.1:5000/          # -> {"message":"Backend is running!"}
```

## 7. nginx
```bash
sudo cp deploy/nginx-seniorconnect.conf /etc/nginx/sites-available/seniorconnect
sudo nano /etc/nginx/sites-available/seniorconnect     # set server_name; check the php-fpm socket name
ls /run/php/                                            # e.g. php8.3-fpm.sock -> use that in fastcgi_pass
sudo ln -s /etc/nginx/sites-available/seniorconnect /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl reload nginx
```

## 8. HTTPS (needs a domain pointing at the server)
```bash
sudo certbot --nginx -d YOUR_DOMAIN
```

## 9. Check it works
- `https://YOUR_DOMAIN/login.php` loads, you can log in as the admin from step 5.
- `https://YOUR_DOMAIN/.env`, `/app.py`, `/database/schema.sql` must all return 403/404.
- Logs if something fails: `sudo journalctl -u seniorconnect -n 50`, `/var/log/nginx/error.log`.

## Updating later
Copy changed files into /var/www/seniorconnect, then `sudo systemctl restart seniorconnect`.

## Without a domain (class demo)
Skip step 8, set `server_name _;` and browse to the server's IP over http.
Don't share it publicly without HTTPS.
