-- SeniorConnect database schema (MySQL / MariaDB)
-- Safe to re-run: it drops and recreates every table.
-- WARNING: re-running DELETES ALL DATA. Do not run it on a live database.

CREATE DATABASE IF NOT EXISTS ITS122P_Database
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE ITS122P_Database;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS event_resources;
DROP TABLE IF EXISTS audit_logs;
DROP TABLE IF EXISTS registrations;
DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS announcements;
DROP TABLE IF EXISTS resources;
DROP TABLE IF EXISTS locations;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS users;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE users (
    user_id       SERIAL       PRIMARY KEY,
    name          VARCHAR(255) NOT NULL,
    phone         VARCHAR(20)  NOT NULL UNIQUE,
    role          ENUM('admin', 'staff', 'attendee') DEFAULT 'attendee',
    -- hashed 4-digit PIN (werkzeug hash string, set via /api/auth/register)
    pin_code      VARCHAR(255),
    is_online     BOOLEAN      DEFAULT FALSE,
    last_login_at TIMESTAMP    NULL,
    -- login attempt protection (used by /api/auth/login)
    failed_attempts INT        NOT NULL DEFAULT 0,
    locked_until    DATETIME   NULL
);

CREATE TABLE categories (
    category_id SERIAL       PRIMARY KEY,
    name        VARCHAR(255) NOT NULL,
    description TEXT
);

CREATE TABLE locations (
    location_id SERIAL       PRIMARY KEY,
    address     VARCHAR(255),
    zip         VARCHAR(20),
    map_link    VARCHAR(255)
);

CREATE TABLE resources (
    resource_id SERIAL       PRIMARY KEY,
	-- Removed location_id, thought about it looked pretty redundant
    name        VARCHAR(255) NOT NULL,
    type        VARCHAR(50),
    status            VARCHAR(50)
);

CREATE TABLE announcements (
    announcement_id SERIAL PRIMARY KEY,
    posted_by BIGINT UNSIGNED NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT,
    time_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    schedule TIMESTAMP NULL,

    FOREIGN KEY (posted_by)
        REFERENCES users(user_id)
        ON DELETE SET NULL
);

CREATE TABLE events (
    event_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    created_by BIGINT UNSIGNED NULL,
    category_id BIGINT UNSIGNED NULL,
    location_id BIGINT UNSIGNED NULL,

    title VARCHAR(255) NOT NULL,
    start_time TIMESTAMP NULL,
    end_time TIMESTAMP NULL,
    capacity INTEGER,

    FOREIGN KEY (created_by)
        REFERENCES users(user_id)
        ON DELETE SET NULL,

    FOREIGN KEY (category_id)
        REFERENCES categories(category_id)
        ON DELETE SET NULL,

    FOREIGN KEY (location_id)
        REFERENCES locations(location_id)
        ON DELETE SET NULL
);

CREATE TABLE registrations (
    registration_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    user_id BIGINT UNSIGNED NOT NULL,

    event_id BIGINT UNSIGNED NOT NULL,

    registration_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    status VARCHAR(50),

    FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE,

    FOREIGN KEY (event_id)
        REFERENCES events(event_id)
        ON DELETE CASCADE
);

CREATE TABLE audit_logs (
    log_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    user_id BIGINT UNSIGNED NULL,

    details TEXT,

    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE SET NULL
);


CREATE TABLE event_resources (
    event_resource_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    event_id BIGINT UNSIGNED NOT NULL,

    resource_id BIGINT UNSIGNED NOT NULL,

    quantity INTEGER,

    FOREIGN KEY (event_id)
        REFERENCES events(event_id)
        ON DELETE CASCADE,

    FOREIGN KEY (resource_id)
        REFERENCES resources(resource_id)
        ON DELETE CASCADE
);
