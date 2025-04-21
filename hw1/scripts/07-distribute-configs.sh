#!/bin/bash
echo "[*] Распространение конфигураций Hadoop..."
for host in tmpl-snn tmpl-dn1 tmpl-dn2; do
  scp ~/hadoop-3.4.0/etc/hadoop/core-site.xml team@$host:~/hadoop-3.4.0/etc/hadoop/
  scp ~/hadoop-3.4.0/etc/hadoop/hdfs-site.xml team@$host:~/hadoop-3.4.0/etc/hadoop/
done
