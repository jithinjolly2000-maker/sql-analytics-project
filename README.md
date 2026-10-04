<div align="center">

# 🗄️ SQL Analytics Project — Compliance / Payments

### A realistic schema + a graded set of 17 analyst queries, from `SELECT` to window functions

![SQL](https://img.shields.io/badge/SQL-SQLite_·_ANSI-003b57?style=flat-square&logo=sqlite&logoColor=white)
![Level](https://img.shields.io/badge/Covers-joins_·_CTEs_·_window_functions-0a7a52?style=flat-square)
![Verified](https://img.shields.io/badge/All_17_queries-run_clean-17854a?style=flat-square)

</div>

---

A compact, **recruiter-readable** demonstration of practical SQL for data / BI / compliance
analysis. The dataset is a small payments-compliance model (markets → vendors → invoices →
transactions) with deliberately realistic quirks: missing VAT registrations, unpaid invoices,
and an unmatched payment — the kinds of things an analyst actually hunts for.

## 📁 Files

| File | What it is |
|------|------------|
| [`schema.sql`](schema.sql) | The schema + seed data — 4 tables, foreign keys, ~50 rows |
| [`queries.sql`](queries.sql) | 17 commented queries, grouped by difficulty |
| This README | A study guide / cheat-sheet you can learn and interview-prep from |

**▶ Want to run these in your browser?** Try the companion
[**SQL Playground**](https://jithinjolly2000-maker.github.io/sql-playground/) (this exact dataset,
live) and the [**SQL Quest game**](https://jithinjolly2000-maker.github.io/sql-quest/).

## 🧱 The schema

```
markets (market_code, country, vat_rate)
   │
   └──< vendors (vendor_id, vendor_name, market_code, vat_number, onboarded_on)
             │
             └──< invoices (invoice_id, vendor_id, invoice_date, net_amount, vat_amount, status)
                       │
                       └──< transactions (txn_id, invoice_id, txn_date, amount, txn_type)
```

## 📚 What the 17 queries cover (study guide)

**Level 1 — the basics:** `SELECT`, `WHERE`, `ORDER BY`
Filtering rows and sorting — the foundation of every query.

**Level 2 — aggregation:** `GROUP BY`, `HAVING`, `COUNT/SUM/AVG`
Collapsing many rows into one summary per group. `WHERE` filters *rows*; `HAVING` filters *groups*.

**Level 3 — JOINs:** `INNER JOIN` across 3 tables
Combining tables on keys. Query 9 is a real **compliance check** — approved invoices from vendors
with a missing VAT number.

**Level 4 — LEFT JOIN & finding what's missing:**
The analyst's power move. `LEFT JOIN … WHERE right.key IS NULL` finds rows on one side with no
match on the other — **unpaid invoices, unmatched payments, dormant vendors.**

**Level 5 — subqueries & CTEs:** `WITH … AS (…)`
Breaking a hard question into readable steps. Query 14 computes each vendor's **% share** of total.

**Level 6 — window functions:** `RANK() OVER (PARTITION BY …)`, `SUM() OVER (ORDER BY …)`, `LAG()`
The senior-analyst toolkit — ranking within groups, running totals, period-over-period change,
all **without collapsing the rows.**

## 🎯 Interview cheat-sheet

| You want to… | Use |
|--------------|-----|
| Filter rows | `WHERE` |
| Summarise groups | `GROUP BY` + `SUM/COUNT/AVG` |
| Filter *after* grouping | `HAVING` |
| Combine tables | `JOIN … ON` |
| Find rows with **no** match | `LEFT JOIN … WHERE x IS NULL` |
| Reuse a result / stay readable | `WITH cte AS (…)` |
| Rank without collapsing rows | `RANK() OVER (PARTITION BY … ORDER BY …)` |
| Running total | `SUM(x) OVER (ORDER BY …)` |
| Compare to previous row | `LAG(x) OVER (ORDER BY …)` |

## ✅ Verified

Every query in `queries.sql` was executed against `schema.sql` (SQLite / SQL.js) — **all 17 run
clean**, and the compliance checks return the planted anomalies (the unregistered vendor's approved
invoice, the unmatched payment).

---

Built by **Jithin J** · [GitHub](https://github.com/jithinjolly2000-maker) · [LinkedIn](https://www.linkedin.com/in/jithin2k)
