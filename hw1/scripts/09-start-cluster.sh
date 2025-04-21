#!/bin/bash
echo "[*] Форматирование NameNode и запуск кластера..."
ssh hadoop@tmpl-nn <<EOF
cd ~/hadoop-3.4.0
bin/hdfs namenode -format -nonInteractive
sbin/start-dfs.sh
EOF
