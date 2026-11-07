# PostgreSQL Slow-Query Audit — Fixed-Scope B2B Service

Independent technical work by **Mhamed Askoure** · Python / PostgreSQL · Remote from Morocco.

**Commercial offer:** A fixed-price **$300 PostgreSQL query-performance audit**, with a written report delivered within **48 hours after** we agree the scope and receive suitable sanitized diagnostics. No production database credentials needed by email.

**Request an audit:** [Email zongsm@gmail.com](mailto:zongsm@gmail.com?subject=PostgreSQL%20Slow%20Query%20Audit%20-%20%24300)

## Who this is for

SaaS, data engineering and API teams experiencing slow SQL endpoints, excessive full-table scans, suboptimal indexes, large PostgreSQL CPU/I/O use, or increased latency under load.

**Audit scope ($300 fixed):**

1. Review up to **three** slow SQL queries, related schemas/index definitions, and sanitized `EXPLAIN (ANALYZE, BUFFERS)` output.
2. Identify likely plan, cardinality, index, parameter and locking bottlenecks supported by the supplied evidence.
3. Deliver a short written report with prioritized recommendations, sample query/index changes, trade-offs, validation commands, and rollback considerations.
4. Provide one asynchronous Q&A round. Any hands-on production deployment, access to sensitive data, or more than three queries is scoped and priced separately.

**Commercial terms:** A funded milestone or an agreed payment method (PayPal or bank) is established **before** starting; no promise of savings or percentage improvements without controlled measurement. Acceptance is based on the agreed written deliverables.

## Demonstration: multi-tenant telemetry query

Consider an event table with millions of rows, multiple tenants and a mostly processed status field. A common application query is:

```sql
SELECT id, tenant_id, event_type, payload, created_at
FROM event_telemetry
WHERE tenant_id = $1
  AND status = 'pending'
  AND created_at >= NOW() - INTERVAL '7 days'
ORDER BY created_at DESC
LIMIT 50;
```

An index worth **testing**, conditional on the actual data distribution and query plans:

```sql
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_telemetry_pending_tenant_created
ON event_telemetry (tenant_id, created_at DESC)
INCLUDE (id, event_type)
WHERE status = 'pending';

ANALYZE event_telemetry;
```

**Why test, rather than blindly deploy?** PostgreSQL may still visit the heap for `payload`; covering large `payload` columns could make the index expensive. Index selectivity, write amplification, table bloat, permissions, active transactions and maintenance overhead must be checked. For minimal downtime, `CREATE INDEX CONCURRENTLY` is run outside a transaction block, with a cleanup plan for failed index builds.

### Evidence and performance claims

This repository provides a **technical design and SQL illustration**, **not** independently validated client production evidence. Historical p95/p99/CPU numbers used in an earlier README have not been substantiated here by a reproducible dataset, raw test logs and execution-plan receipts, so they are not offered as measured business outcomes. Any improvement for a client must be measured **before and after** under comparable load, with a recorded baseline.

### Related public work

- [PostgreSQL Data Manager (Python / SSH / database operations)](https://github.com/zongsm-cmyk/kaggle_postgre_challenge)
- [Python / FastAPI API reliability work](https://github.com/zongsm-cmyk/llm-reliability-rescue-demo)

## Start with a paid diagnosis

Email **zongsm@gmail.com** with:

- PostgreSQL major version and hosting environment.
- A brief description of the affected workload and success criterion.
- Up to 3 sanitized queries, `EXPLAIN (ANALYZE, BUFFERS)` plans and relevant indexes (redact PII, credentials and confidential literals).
- Whether a 48-hour written audit for $300 matches your budget.

I'll confirm fit, written scope, acceptance criteria, payment arrangement, and the start time before requesting any work.
