#!/bin/bash
# Установка Hive и драйвера PostgreSQL

wget https://archive.apache.org/dist/hive/hive-4.0.0-alpha-2/apache-hive-4.0.0-alpha-2-bin.tar.gz
tar -xzvf apache-hive-4.0.0-alpha-2-bin.tar.gz
cd apache-hive-4.0.0-alpha-2-bin/lib
wget https://jdbc.postgresql.org/download/postgresql-42.7.4.jar
