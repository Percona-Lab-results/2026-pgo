# MySQL 9.7.0 PGO Benchmark Analysis

This project contains performance benchmark results comparing Profile-Guided Optimization (PGO) and non-PGO builds of MySQL Server 9.7.0, along with Percona Server 8.4.8-8 as a baseline.

## Overview

**Servers Tested:**
- **MySQL 9.7.0** (PGO-enabled build)
- **MySQL 9.7.0 Non-PGO** (built without Profile-Guided Optimization)
- **Percona Server 8.4.8-8** (no PGO available)

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
├── benchmark_logs/          # Raw benchmark data and logs
│   ├── mysql/              # MySQL 9.7.0 (PGO)
│   ├── mysql-non-pgo/      # MySQL 9.7.0 (no PGO)
│   └── percona-server/     # Percona Server 8.4.8-8
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
└── README.md               # This file
```

## Key Findings

The interactive reports allow for detailed analysis of:
- Performance differences between PGO and non-PGO MySQL builds
- Impact of different buffer pool sizes on performance
- Scaling characteristics across different thread counts
- Storage engine behavior differences
- Configuration and runtime variable differences

### Percona Server Performance at 32 and 64 Threads

During testing, we observed that **Percona Server 8.4.8-8 shows lower performance compared to MySQL 9.7.0 at 32 and 64 thread counts**. This performance gap was investigated in a separate dedicated benchmark study.

📊 **[Percona Server vs MySQL Performance Investigation](https://github.com/Percona-Lab-results/2026-ps-vs-mysql/blob/main/README.md)**

The separate investigation provides:
- Detailed analysis of the performance regression
- Comparison across multiple configurations
- Root cause analysis
- Recommended optimizations

This behavior is specific to certain thread count ranges and may be related to internal locking, thread scheduling, or other concurrency-related differences between Percona Server 8.4.8-8 and MySQL 9.7.0.

## Building MySQL with PGO

The MySQL non-PGO build was created using the build system documented in the `mysql-9.7.0-build/` directory, which compiles MySQL from source on Oracle Linux 9.7 and packages it as a Docker image.

## License

Benchmark data and analysis scripts are provided for educational and research purposes.

## Contact

For questions or issues, please open an issue in the repository.

---

**Last Updated**: May 2026  
**MySQL Versions**: 9.7.0  
**Percona Server Version**: 8.4.8-8
