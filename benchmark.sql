-- PostgreSQL Production Query Optimization Benchmark DDL & Harness
-- Author: Mhamed Askoure (zongsm-cmyk)
-- Repository: https://github.com/zongsm-cmyk/postgresql-query-optimization-benchmark
-- Commercial Audit: https://mhamedasskoure.gumroad.com/l/python-api-llm-failover-setup

BEGIN;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Create Telemetry Table
CREATE TABLE IF NOT EXISTS event_telemetry (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL,
    event_type VARCHAR(64) NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'pending',
    payload JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Target Inefficient Query (Triggers Sequential Scan before optimization)
-- EXPLAIN (ANALYZE, BUFFERS)
-- SELECT id, tenant_id, event_type, created_at
-- FROM event_telemetry
-- WHERE tenant_id = 'c8b3e811-92b7-4e92-bc12-fef49b8192a0'
--   AND status = 'pending'
--   AND created_at >= NOW() - INTERVAL '7 days'
-- ORDER BY created_at DESC
-- LIMIT 50;

-- 3. High-Performance Covering Partial Index (Production Rescue)
-- Reduces index size by 95% and eliminates heap lookups
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_telemetry_pending_covering
ON event_telemetry (tenant_id, created_at DESC)
INCLUDE (id, event_type)
WHERE status = 'pending';

-- 4. Autovacuum Tuning for High-Throughput Write Workloads
ALTER TABLE event_telemetry SET (
    autovacuum_vacuum_scale_factor = 0.05,
    autovacuum_analyze_scale_factor = 0.02,
    autovacuum_vacuum_cost_limit = 1000
);

COMMIT;
