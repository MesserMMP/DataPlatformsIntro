#!/bin/bash
echo "[*] Установка Java и переменных среды..."
for host in tmpl-nn tmpl-snn tmpl-dn1 tmpl-dn2; do
  ssh team@$host <<'EOF'
    sudo apt update
    sudo apt install -y openjdk-11-jdk
    echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> ~/.bashrc
    echo 'export PATH=$PATH:$JAVA_HOME/bin' >> ~/.bashrc
    source ~/.bashrc
EOF
done
