-- OPTIONAL demo data for testing only. DO NOT load this on a public site.
-- Creates 'Test Admin' (09123456789) and 'John Test' (09123456780), both PIN 1234.
-- (PINs are plain here; the app converts them to hashes on first login.)
USE ITS122P_Database;

INSERT INTO users (
    name,
    phone,
    role,
    pin_code
)
VALUES (
    'Test Admin',
    '09123456789',
    'admin',
    '1234'
);

INSERT INTO announcements (
    posted_by,
    title,
    content
)
VALUES (
    1,
    'Test Announcement',
    'This is a test announcement.'
);

INSERT INTO users (
    name,
    phone,
    role,
    pin_code
)
VALUES (
    'John Test',
    '09123456780',
    'attendee',
    '1234'
);

INSERT INTO categories (
    name,
    description
)
VALUES (
    'Workshop',
    'Educational workshops and training sessions'
);

INSERT INTO locations (
    address,
    zip,
    map_link
)
VALUES (
    'Makati City Hall',
    '1200',
    'https://maps.google.com/'
);

INSERT INTO resources (
    name,
    type,
    status
)
VALUES (
    'Projector',
    'Equipment',
    'Available'
);

INSERT INTO events (
    created_by,
    category_id,
    location_id,
    title,
    start_time,
    end_time,
    capacity
)
VALUES (
    1,
    1,
    1,
    'Test Workshop',
    DATE_ADD(NOW(), INTERVAL 14 DAY),
    DATE_ADD(DATE_ADD(NOW(), INTERVAL 14 DAY), INTERVAL 3 HOUR),
    50
);

INSERT INTO registrations (
    user_id,
    event_id,
    status
)
VALUES (
    2,
    1,
    'Registered'
);

INSERT INTO audit_logs (
    user_id,
    details
)
VALUES (
    1,
    'Created the Test Workshop event.'
);

INSERT INTO event_resources (
    event_id,
    resource_id,
    quantity
)
VALUES (
    1,
    1,
    2
);



show tables;
