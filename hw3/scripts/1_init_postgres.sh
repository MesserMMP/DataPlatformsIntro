#!/bin/bash
# Установка и настройка PostgreSQL

sudo apt update
sudo apt install -y postgresql postgresql-contrib

sudo -u postgres psql <<EOF
CREATE DATABASE metastore;
CREATE USER hive WITH PASSWORD 'hiveMegaPass';
GRANT ALL PRIVILEGES ON DATABASE metastore TO hive;
ALTER DATABASE metastore OWNER TO hive;
EOF

sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/*/main/postgresql.conf
sudo sed -i "s/port = 5432/port = 5433/" /etc/postgresql/*/main/postgresql.conf

echo "host    metastore       hive            0.0.0.0/0          password" | sudo tee -a /etc/postgresql/*/main/pg_hba.conf

sudo systemctl restart postgresql
