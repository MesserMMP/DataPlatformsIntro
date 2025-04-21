#!/bin/bash
echo "[*] Обновление hostname..."
declare -A hosts=(
  [tmpl-nn]=192.168.1.14
  [tmpl-snn]=192.168.1.15
  [tmpl-dn1]=192.168.1.16
  [tmpl-dn2]=192.168.1.17
)
for name in "${!hosts[@]}"; do
  ssh team@${hosts[$name]} "echo '$name' | sudo tee /etc/hostname && sudo hostnamectl set-hostname $name"
done
