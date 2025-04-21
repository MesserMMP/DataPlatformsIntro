#!/bin/bash
echo "[*] Распаковка и распространение Hadoop..."
tar -czf hadoop-3.4.0.tar.gz hadoop-3.4.0
for host in tmpl-snn tmpl-dn1 tmpl-dn2; do
  scp hadoop-3.4.0.tar.gz team@$host:/tmp/
  ssh team@$host <<EOF
    tar -xzf /tmp/hadoop-3.4.0.tar.gz -C ~/
    rm /tmp/hadoop-3.4.0.tar.gz
EOF
done
