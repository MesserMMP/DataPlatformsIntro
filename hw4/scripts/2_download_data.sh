#!/bin/bash
set -e

sudo -i -u hadoop bash <<EOF
hdfs dfs -mkdir -p /input
wget -nc https://raw.githubusercontent.com/MesserMMP/Datasets/main/Electric_Vehicle_Population_Data.csv -O electric_vehicles.csv
hdfs dfs -put -f electric_vehicles.csv /input
EOF

echo "✅ Данные загружены в HDFS"
