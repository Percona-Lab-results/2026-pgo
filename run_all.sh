#!/bin/bash

# Check if Docker is installed
if ! command -v docker >/dev/null 2>&1; then
    echo "Error: Docker is not installed." >&2
    exit 1
fi

# Check if MySQL client is installed
if ! command -v mysql >/dev/null 2>&1; then
    echo "Error: MySQL client is not installed." >&2
    exit 1
fi

# Check if current user is in the docker group
if ! groups "$USER" | grep -q "\bdocker\b"; then
    echo "Error: User '$USER' is not in the docker group." >&2
    exit 1
fi


sudo apt update
sudo apt install sysstat sysbench dstat -y


./run_pt_summary.sh
./run_pt_mysql_summary.sh

IS_READ_ONLY="0"
VERSIONS=("9.7.0")

for VERSION in "${VERSIONS[@]}"; do
  ./run_metrics.sh "mysql-non-pgo-2" "$VERSION" "$IS_READ_ONLY"
#  ./run_metrics.sh "mysql" "$VERSION" "$IS_READ_ONLY"
done

# ./run_metrics.sh "percona-server" "8.4.8" "0"


echo ""
echo "=========================================================================="
echo "All benchmarks completed!"
echo "=========================================================================="