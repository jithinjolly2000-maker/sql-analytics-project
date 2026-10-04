-- ============================================================
--  Graded query set — from basics to window functions & CTEs.
--  Runs on the schema in schema.sql (SQLite).
--  Each query has a plain-English goal above it.
-- ============================================================

-- ---------- LEVEL 1 · SELECT / WHERE / ORDER BY ----------

-- 1. All approved invoices, newest first.
SELECT invoice_id, vendor_id, invoice_date, net_amount
FROM invoices
WHERE status = 'Approved'
ORDER BY invoice_date DESC;

-- 2. Vendors onboarded in 2025.
SELECT vendor_name, market_code, onboarded_on
FROM vendors
WHERE onboarded_on >= '2025-01-01'
ORDER BY onboarded_on;

-- 3. Invoices above a 10,000 net value (the ones worth reviewing first).
SELECT invoice_id, net_amount, status
FROM invoices
WHERE net_amount > 10000
ORDER BY net_amount DESC;

-- ---------- LEVEL 2 · Aggregation (GROUP BY / HAVING) ----------

-- 4. Invoice count and total net by status.
SELECT status, COUNT(*) AS invoice_count, SUM(net_amount) AS total_net
FROM invoices
GROUP BY status
ORDER BY total_net DESC;

-- 5. Average invoice value per vendor, only vendors averaging over 8,000.
SELECT vendor_id, ROUND(AVG(net_amount), 2) AS avg_net, COUNT(*) AS n
FROM invoices
GROUP BY vendor_id
HAVING AVG(net_amount) > 8000
ORDER BY avg_net DESC;

-- 6. Total VAT collected per calendar month.
SELECT substr(invoice_date, 1, 7) AS month, ROUND(SUM(vat_amount), 2) AS vat_total
FROM invoices
GROUP BY month
ORDER BY month;

-- ---------- LEVEL 3 · JOINs ----------

-- 7. Invoices with vendor name and country (INNER JOIN across 3 tables).
SELECT i.invoice_id, v.vendor_name, m.country, i.net_amount, i.status
FROM invoices i
JOIN vendors v ON v.vendor_id = i.vendor_id
JOIN markets m ON m.market_code = v.market_code
ORDER BY i.invoice_id;

-- 8. Total approved net amount by country.
SELECT m.country, ROUND(SUM(i.net_amount), 2) AS approved_net
FROM invoices i
JOIN vendors v ON v.vendor_id = i.vendor_id
JOIN markets m ON m.market_code = v.market_code
WHERE i.status = 'Approved'
GROUP BY m.country
ORDER BY approved_net DESC;

-- 9. Compliance gap: approved invoices from vendors with NO VAT number.
--    (A real audit check — you shouldn't approve invoices for unregistered vendors.)
SELECT v.vendor_name, m.country, i.invoice_id, i.net_amount
FROM invoices i
JOIN vendors v ON v.vendor_id = i.vendor_id
JOIN markets m ON m.market_code = v.market_code
WHERE v.vat_number IS NULL
  AND i.status = 'Approved';

-- ---------- LEVEL 4 · LEFT JOIN / finding what's missing ----------

-- 10. Unpaid invoices: approved invoices with no matching payment transaction.
SELECT i.invoice_id, i.net_amount + i.vat_amount AS gross_due
FROM invoices i
LEFT JOIN transactions t
       ON t.invoice_id = i.invoice_id AND t.txn_type = 'Payment'
WHERE i.status = 'Approved'
  AND t.txn_id IS NULL
ORDER BY gross_due DESC;

-- 11. Unmatched payments: transactions not linked to any invoice (a reconciliation break).
SELECT t.txn_id, t.txn_date, t.amount
FROM transactions t
WHERE t.invoice_id IS NULL;

-- 12. Vendors with zero invoices (onboarded but never transacted).
SELECT v.vendor_name, v.onboarded_on
FROM vendors v
LEFT JOIN invoices i ON i.vendor_id = v.vendor_id
WHERE i.invoice_id IS NULL;

-- ---------- LEVEL 5 · Subqueries & CTEs ----------

-- 13. Invoices larger than the overall average net (subquery in WHERE).
SELECT invoice_id, net_amount
FROM invoices
WHERE net_amount > (SELECT AVG(net_amount) FROM invoices)
ORDER BY net_amount DESC;

-- 14. Each vendor's share of total approved net (CTE + cross join to the grand total).
WITH approved AS (
    SELECT vendor_id, SUM(net_amount) AS vendor_net
    FROM invoices
    WHERE status = 'Approved'
    GROUP BY vendor_id
),
grand AS (
    SELECT SUM(vendor_net) AS total_net FROM approved
)
SELECT v.vendor_name,
       ROUND(a.vendor_net, 2) AS vendor_net,
       ROUND(100.0 * a.vendor_net / g.total_net, 1) AS pct_of_total
FROM approved a
JOIN vendors v ON v.vendor_id = a.vendor_id
CROSS JOIN grand g
ORDER BY pct_of_total DESC;

-- ---------- LEVEL 6 · Window functions ----------

-- 15. Rank vendors by approved net within each country (RANK + PARTITION BY).
WITH v_net AS (
    SELECT v.vendor_id, v.vendor_name, m.country, SUM(i.net_amount) AS net
    FROM invoices i
    JOIN vendors v ON v.vendor_id = i.vendor_id
    JOIN markets m ON m.market_code = v.market_code
    WHERE i.status = 'Approved'
    GROUP BY v.vendor_id, v.vendor_name, m.country
)
SELECT country, vendor_name, ROUND(net, 2) AS net,
       RANK() OVER (PARTITION BY country ORDER BY net DESC) AS rank_in_country
FROM v_net
ORDER BY country, rank_in_country;

-- 16. Running total of monthly VAT over the year (cumulative sum).
WITH monthly AS (
    SELECT substr(invoice_date, 1, 7) AS month, SUM(vat_amount) AS vat
    FROM invoices
    GROUP BY month
)
SELECT month,
       ROUND(vat, 2) AS vat_month,
       ROUND(SUM(vat) OVER (ORDER BY month), 2) AS vat_running
FROM monthly
ORDER BY month;

-- 17. Month-over-month change in invoice volume (LAG).
WITH monthly AS (
    SELECT substr(invoice_date, 1, 7) AS month, COUNT(*) AS cnt
    FROM invoices
    GROUP BY month
)
SELECT month, cnt,
       cnt - LAG(cnt) OVER (ORDER BY month) AS change_vs_prev
FROM monthly
ORDER BY month;
