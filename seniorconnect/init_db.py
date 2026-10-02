"""Create any missing tables (safe to run on every start; never deletes data)
and, optionally, the first admin account.

Admin is created only if ADMIN_NAME, ADMIN_PHONE and ADMIN_PIN are all set
AND no account with that phone exists yet.
"""
import os
import re

from werkzeug.security import generate_password_hash

from app import app, db, User

import pathlib
import re as _re

from sqlalchemy import inspect, text


def create_tables_from_schema():
    """Create missing tables from database/schema.sql (the official schema).

    Only CREATE TABLE statements are executed (as CREATE TABLE IF NOT EXISTS), so
    this never drops or changes existing data. The DROP/CREATE DATABASE/USE lines
    in schema.sql are skipped on purpose.
    """
    sql = pathlib.Path(__file__).with_name("database").joinpath("schema.sql").read_text()
    sql = _re.sub(r"--[^\n]*", "", sql)                      # strip comments
    for stmt in (p.strip() for p in sql.split(";")):
        if stmt.upper().startswith("CREATE TABLE"):
            stmt = _re.sub(r"^CREATE TABLE\s+", "CREATE TABLE IF NOT EXISTS ", stmt, flags=_re.I)
            db.session.execute(text(stmt))
    db.session.commit()


with app.app_context():
    if db.engine.dialect.name == "mysql":
        create_tables_from_schema()
    else:
        db.create_all()          # sqlite etc. (tests only)
    print("[init_db] tables ready:", ", ".join(sorted(inspect(db.engine).get_table_names())))

    name = os.getenv("ADMIN_NAME", "").strip()
    phone = os.getenv("ADMIN_PHONE", "").strip()
    pin = os.getenv("ADMIN_PIN", "").strip()

    if name and phone and pin:
        if not re.fullmatch(r"\d{4}", pin):
            print("[init_db] ADMIN_PIN must be exactly 4 digits; admin not created")
        elif User.query.filter_by(phone=phone).first():
            print("[init_db] admin phone already exists; nothing changed")
        else:
            db.session.add(User(name=name, phone=phone, role="admin",
                                pin_code=generate_password_hash(pin)))
            db.session.commit()
            print("[init_db] admin account created")
