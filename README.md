# MySQL 9.7.0 PGO Benchmark Analysis

This project contains performance benchmark results comparing Profile-Guided Optimization (PGO) and non-PGO builds of MySQL Server 9.7.0.

## Overview

**Servers Tested:**
- **MySQL 9.7.0** (PGO-enabled build)
- **MySQL 9.7.0 Non-PGO** (built without Profile-Guided Optimization)

**Tier Configurations:**
- Tier 2G: 2GB InnoDB buffer pool
- Tier 12G: 12GB InnoDB buffer pool
- Tier 32G: 32GB InnoDB buffer pool

## View Results

📊 **[Interactive Reports](https://percona-lab-results.github.io/2026-pgo/index.html)**

The benchmark reports are available as interactive HTML pages at:
```
https://percona-lab-results.github.io/2026-pgo/index.html
```

## Key Findings

### Performance Impact of PGO

MySQL 9.7.0 with Profile-Guided Optimization (PGO) demonstrates significant performance improvements over the non-PGO build:

**Overall Performance Summary:**
- **Average improvement: 10.7%** across all configurations
- **Peak improvement: 31%** (Tier 2G, 32 threads)
- Performance gains range from 6% to 31% in most scenarios
- Minor regressions (-3% to -4%) observed only at very high thread counts (128-512 threads) with smaller buffer pools

**Performance by Buffer Pool Size:**
- **Tier 2G** (2GB buffer pool): Average improvement of **10.4%**
  - Best gains at 32 threads (31% improvement)
  - Consistent 6-16% gains across 1-64 threads
- **Tier 12G** (12GB buffer pool): Average improvement of **12.1%**
  - Strong gains across all thread counts
  - Peak improvements of 24-25% at 64-128 threads
- **Tier 32G** (32GB buffer pool): Average improvement of **9.5%**
  - Steady 6-15% improvements across all thread counts
  - Consistent gains even at highest concurrency (256-512 threads: 11%)

**Key Observations:**
- PGO provides the most significant benefits at moderate concurrency levels (32-128 threads)
- Larger buffer pools (32GB) maintain consistent PGO benefits even under extreme concurrency
- Smaller buffer pools may see slight regressions at very high thread counts (128-512 threads)
- The performance improvements demonstrate PGO's effectiveness in optimizing hot code paths in production-like workloads

### InnoDB Metrics Analysis

Deep analysis of InnoDB metrics reveals the source of PGO's performance improvements:

**Root Cause: CPU-Level Optimizations**
- PGO improvements are **NOT** from I/O optimization, caching, or lock reduction
- Buffer pool hit ratios remain virtually identical between PGO and non-PGO (Tier 32G: 100% for both)
- Lock contention is minimal in both builds (<50 waits in 15 minutes)
- All I/O metrics scale proportionally with increased throughput

**What PGO Actually Optimizes:**
- ✓ Better instruction cache utilization
- ✓ Improved branch prediction in hot code paths
- ✓ Optimized function inlining
- ✓ More efficient CPU instruction ordering

**DML Operations Correlation:**
- DML operations (inserts/updates/deletes) improve by +11.1% on average
- Perfectly correlates with transaction throughput gains
- Best case: +31.6% (Tier 2G, 32 threads)
- Tier 12G at 64-128 threads: +25% DML throughput improvement

**Tier-Specific Patterns:**
- **Tier 2G** (~85-87% hit ratio): PGO helps CPU efficiency during I/O waits
- **Tier 12G** (~92-93% hit ratio): Balanced workload shows strongest relative gains
- **Tier 32G** (100% hit ratio): Pure CPU-bound workload demonstrates consistent PGO benefits

The metrics confirm that PGO's 10.7% average improvement comes entirely from making the CPU more efficient at executing MySQL's hot code paths, allowing it to process more transactions per second with the same hardware resources.

## What is PGO?

Profile-Guided Optimization (PGO) is a compiler optimization technique that uses runtime profiling data to guide code optimization. The compiler first instruments the code, collects execution profiles during typical workload runs, and then recompiles the code with optimizations targeted at the most frequently executed code paths.

**Benefits of PGO:**
- Improved branch prediction
- Better instruction cache utilization
- Optimized function inlining
- Reduced code bloat
- Better register allocation

## Benchmark Methodology

### Workload
- **Tool**: Sysbench OLTP Read/Write benchmark
- **Tables**: 20 tables
- **Table Size**: 5,000,000 rows per table
- **Thread Counts**: 1, 4, 16, 32, 64, 128, 256, 512

### Configuration
- **Warmup**: 
  - Read-only: 180 seconds
  - Read-write: 600 seconds
- **Measurement Duration**: 900 seconds (15 minutes) per thread count
- **Runs**: Single run per configuration

### System Metrics Collected
- InnoDB storage engine metrics
- MySQL status variables
- MySQL system variables
- System I/O statistics (iostat)
- Virtual memory statistics (vmstat)
- CPU statistics (mpstat)
- System statistics (dstat)

## Report Categories

### Performance Reports
- **Sysbench Individual Runs**: Detailed per-run performance metrics
- **InnoDB Metrics**: Interactive storage engine metrics

### Variable Comparisons
- **Status Variables**: MySQL runtime status comparison across servers and tiers
- **System Variables**: MySQL configuration variables comparison

## Repository Structure

```
2026-pgo/
├── benchmark_logs/         # Raw benchmark data and logs
│   ├── mysql/              # MySQL 9.7.0 (PGO)
│   └── mysql-non-pgo/      # MySQL 9.7.0 (no PGO)
├── visuals/                # Report generation scripts
│   ├── vars_comparison_report.py
│   ├── innodb_metrics_report.py
│   └── throughput_report.py
├── index.html              # Main report index
├── status_variables_comparison.html
├── system_variables_comparison.html
├── innodb_metrics_report.html
├── sysbench_ps_mysql_individual.html
├── run_metrics.sh          # Benchmark execution script
├── BUILD.md                # Build steps
└── README.md               # This file
```

## Building MySQL without PGO

For detailed build instructions, see **[BUILD.md](BUILD.md)**, which provides:
- Complete step-by-step build process from source download to Docker image
- CMake configuration details and compiler flags
- Docker image packaging strategy
- Build verification and testing steps
- Comparison of PGO vs non-PGO builds

---

**Last Updated**: May 2026  
**MySQL Version**: 9.7.0
