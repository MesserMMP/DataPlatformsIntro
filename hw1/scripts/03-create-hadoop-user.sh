#!/bin/bash
echo "[*] Создание пользователя hadoop на всех узлах..."
for host in tmpl-nn tmpl-snn tmpl-dn1 tmpl-dn2; do
  ssh team@$host <<EOF
    sudo useradd -m -s /bin/bash hadoop
    echo "hadoop:hadoop" | sudo chpasswd
    sudo usermod -aG sudo hadoop
EOF
done
