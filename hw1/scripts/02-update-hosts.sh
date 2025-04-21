#!/bin/bash
echo "[*] Обновление /etc/hosts на всех узлах..."
cat <<EOF | sudo tee -a /etc/hosts
192.168.1.14 tmpl-nn
192.168.1.15 tmpl-snn
192.168.1.16 tmpl-dn1
192.168.1.17 tmpl-dn2
EOF
for host in tmpl-snn tmpl-dn1 tmpl-dn2; do
  echo "[*] Копирование hosts на $host"
  scp /etc/hosts team@$host:/tmp/
  ssh team@$host 'sudo mv /tmp/hosts /etc/hosts'
done
