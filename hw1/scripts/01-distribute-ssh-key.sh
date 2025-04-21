#!/bin/bash
echo "[*] Генерация ssh-ключа..."
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
echo "[*] Добавление в authorized_keys..."
cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
echo "[*] Распространение ключа на остальные узлы..."
for host in 192.168.1.15 192.168.1.16 192.168.1.17; do
  echo "[*] Отправка на $host"
  ssh-copy-id team@$host
done
