-- ============================================================
--  SQL Analytics Project — Compliance / Payments dataset
--  A small but realistic schema for practising analyst SQL.
--  Dialect: SQLite (also runs with minor tweaks on Postgres/MySQL).
-- ============================================================

-- ---------- Schema ----------
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS invoices;
DROP TABLE IF EXISTS vendors;
DROP TABLE IF EXISTS markets;

CREATE TABLE markets (
    market_code TEXT PRIMARY KEY,   -- e.g. 'DE'
    country     TEXT NOT NULL,
    vat_rate    REAL NOT NULL       -- standard VAT %
);

CREATE TABLE vendors (
    vendor_id    INTEGER PRIMARY KEY,
    vendor_name  TEXT NOT NULL,
    market_code  TEXT NOT NULL REFERENCES markets(market_code),
    vat_number   TEXT,              -- NULL = missing registration (a compliance gap)
    onboarded_on TEXT NOT NULL      -- ISO date
);

CREATE TABLE invoices (
    invoice_id   INTEGER PRIMARY KEY,
    vendor_id    INTEGER NOT NULL REFERENCES vendors(vendor_id),
    invoice_date TEXT NOT NULL,
    net_amount   REAL NOT NULL,
    vat_amount   REAL NOT NULL,
    status       TEXT NOT NULL      -- 'Approved' | 'Pending' | 'Rejected'
);

CREATE TABLE transactions (
    txn_id      INTEGER PRIMARY KEY,
    invoice_id  INTEGER REFERENCES invoices(invoice_id),  -- NULL = unmatched payment
    txn_date    TEXT NOT NULL,
    amount      REAL NOT NULL,
    txn_type    TEXT NOT NULL       -- 'Payment' | 'Refund'
);

-- ---------- Reference data ----------
INSERT INTO markets (market_code, country, vat_rate) VALUES
 ('DE','Germany',19),
 ('FR','France',20),
 ('IT','Italy',22),
 ('ES','Spain',21),
 ('NL','Netherlands',21),
 ('UK','United Kingdom',20);

-- ---------- Vendors (note: some vat_number are NULL = compliance gaps) ----------
INSERT INTO vendors (vendor_id, vendor_name, market_code, vat_number, onboarded_on) VALUES
 (1,'Nordwind GmbH','DE','DE123456789','2024-02-11'),
 (2,'Lumina SARL','FR','FR12345678901','2024-03-04'),
 (3,'Orbit Ltd','UK',NULL,'2024-04-20'),
 (4,'Vireo B.V.','NL','NL123456789B01','2024-05-15'),
 (5,'Pallas S.L.','ES','ES12345678','2024-06-01'),
 (6,'Castor GmbH','DE','DE987654321','2024-06-18'),
 (7,'Meridian Ltd','UK','GB987654321','2024-07-02'),
 (8,'Solace S.p.A.','IT',NULL,'2024-08-09'),
 (9,'Tindra Ltd','UK','GB111222333','2025-01-12'),
 (10,'Halcyon B.V.','NL','NL998877665B01','2025-02-28'),
 (11,'Ferro S.p.A.','IT','IT55566677788','2025-03-30'),
 (12,'Juniper SARL','FR',NULL,'2025-05-05');

-- ---------- Invoices ----------
INSERT INTO invoices (invoice_id, vendor_id, invoice_date, net_amount, vat_amount, status) VALUES
 (1001,1,'2025-01-15',12450.00,2365.50,'Approved'),
 (1002,2,'2025-01-18', 8800.50,1760.10,'Approved'),
 (1003,3,'2025-01-22', 4300.00, 860.00,'Pending'),
 (1004,4,'2025-02-03',15600.00,3276.00,'Approved'),
 (1005,5,'2025-02-10', 2200.00, 462.00,'Rejected'),
 (1006,6,'2025-02-14', 9900.00,1881.00,'Approved'),
 (1007,7,'2025-02-20', 3100.75, 620.15,'Approved'),
 (1008,1,'2025-03-01', 7600.00,1444.00,'Approved'),
 (1009,8,'2025-03-05',  760.00, 167.20,'Pending'),
 (1010,2,'2025-03-11', 5400.00,1080.00,'Approved'),
 (1011,9,'2025-03-19',22000.00,4400.00,'Approved'),
 (1012,10,'2025-04-02', 1200.00, 252.00,'Pending'),
 (1013,11,'2025-04-14',18750.00,4125.00,'Approved'),
 (1014,6,'2025-04-21',  450.00,  85.50,'Rejected'),
 (1015,4,'2025-05-06',27300.00,5733.00,'Approved'),
 (1016,12,'2025-05-19', 3400.00, 680.00,'Approved'),
 (1017,1,'2025-06-02', 9100.00,1729.00,'Approved'),
 (1018,7,'2025-06-15', 6650.00,1330.00,'Pending'),
 (1019,11,'2025-06-23',14200.00,3124.00,'Approved'),
 (1020,9,'2025-07-01',  980.00, 196.00,'Approved');

-- ---------- Transactions (some invoices unpaid; one unmatched payment) ----------
INSERT INTO transactions (txn_id, invoice_id, txn_date, amount, txn_type) VALUES
 (1,1001,'2025-01-28',14815.50,'Payment'),
 (2,1002,'2025-02-01',10560.60,'Payment'),
 (3,1004,'2025-02-20',18876.00,'Payment'),
 (4,1006,'2025-02-28',11781.00,'Payment'),
 (5,1007,'2025-03-05', 3720.90,'Payment'),
 (6,1008,'2025-03-15', 9044.00,'Payment'),
 (7,1010,'2025-03-25', 6480.00,'Payment'),
 (8,1011,'2025-04-02',26400.00,'Payment'),
 (9,1013,'2025-04-28',22875.00,'Payment'),
 (10,1005,'2025-02-15',  200.00,'Refund'),
 (11,1015,'2025-05-20',33033.00,'Payment'),
 (12,1017,'2025-06-12',10829.00,'Payment'),
 (13,1019,'2025-07-01',17324.00,'Payment'),
 (14,NULL,'2025-07-03', 5000.00,'Payment');  -- unmatched: no linked invoice
