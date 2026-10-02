"""Create (or reset) an admin account with a hashed PIN.

Run on the server, from the project folder, with the venv active:
    set -a; . /etc/seniorconnect.env; set +a
    python create_admin.py
"""
import getpass
import re

from werkzeug.security import generate_password_hash

from app import app, db, User

name = input("Admin full name: ").strip()
phone = input("Admin phone number: ").strip()
pin = getpass.getpass("4-digit PIN: ").strip()

if not re.fullmatch(r"[A-Za-zÀ-ÿ\s'-]+", name):
    raise SystemExit("Name must contain letters only.")
if not phone:
    raise SystemExit("Phone is required.")
if not (pin.isdigit() and len(pin) == 4):
    raise SystemExit("PIN must be exactly 4 digits.")

with app.app_context():
    user = User.query.filter_by(phone=phone).first()
    if user:
        user.name, user.role = name, "admin"
        user.pin_code = generate_password_hash(pin)
        user.failed_attempts, user.locked_until = 0, None
        print("Existing account updated and promoted to admin.")
    else:
        db.session.add(User(name=name, phone=phone, role="admin",
                            pin_code=generate_password_hash(pin)))
        print("Admin account created.")
    db.session.commit()
