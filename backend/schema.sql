-- =====================================================================
-- Activity 10 - Event Venue and Micro-Vendor Finder
-- PostgreSQL schema (IT 108 Advanced Database Management Systems)
--
-- Run with:
--   psql -U eventvenue -d eventvenue_db -f schema.sql
-- =====================================================================

-- ---------------------------------------------------------------- users
CREATE TABLE IF NOT EXISTS users (
    user_id    INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username   VARCHAR(60)  NOT NULL UNIQUE,
    password   VARCHAR(255) NOT NULL,
    full_name  VARCHAR(120) NOT NULL,
    email      VARCHAR(150) UNIQUE,
    role       VARCHAR(20)  NOT NULL DEFAULT 'client'
                       CHECK (role IN ('client', 'vendor', 'admin')),
    created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- --------------------------------------------------------------- venues
CREATE TABLE IF NOT EXISTS venues (
    venue_id   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name       VARCHAR(150) NOT NULL,
    type       VARCHAR(40)  NOT NULL
                       CHECK (type IN ('venue', 'catering', 'decor', 'photo', 'sound')),
    location   VARCHAR(100) NOT NULL,
    capacity   INTEGER      NOT NULL CHECK (capacity > 0),
    price_min  NUMERIC(12,2) NOT NULL CHECK (price_min >= 0),
    price_max  NUMERIC(12,2) NOT NULL CHECK (price_max >= price_min),
    owner_id   INTEGER REFERENCES users(user_id) ON DELETE SET NULL,
    created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- -------------------------------------------------------------- reports
CREATE TABLE IF NOT EXISTS reports (
    report_id   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    reference   VARCHAR(20)  NOT NULL UNIQUE,
    title       VARCHAR(150) NOT NULL CHECK (char_length(title) >= 5),
    category    VARCHAR(60)  NOT NULL
                        CHECK (category IN ('Venue Listing Issue',
                                            'Booking / Reservation Problem',
                                            'Payment or Refund Issue',
                                            'Content or Safety Concern',
                                            'Suggestion / Feature Request',
                                            'Other')),
    location    VARCHAR(100) NOT NULL,
    description TEXT         NOT NULL CHECK (char_length(description) >= 10),
    contact     VARCHAR(40),
    status      VARCHAR(20)  NOT NULL DEFAULT 'open'
                        CHECK (status IN ('open', 'reviewing', 'resolved')),
    venue_id    INTEGER REFERENCES venues(venue_id) ON DELETE SET NULL,
    user_id     INTEGER REFERENCES users(user_id)     ON DELETE SET NULL,
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_reports_status  ON reports (status);
CREATE INDEX IF NOT EXISTS idx_reports_created ON reports (created_at DESC);

-- ---------------------------------------------------------------- views
CREATE OR REPLACE VIEW v_report_summary AS
SELECT r.report_id,
       r.reference,
       r.title,
       r.category,
       r.location,
       r.status,
       r.created_at,
       v.name AS venue_name
FROM reports r
LEFT JOIN venues v ON v.venue_id = r.venue_id;
