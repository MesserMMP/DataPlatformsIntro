#!/bin/bash
# Инициализация Hive и запуск HiveServer2

cd ~/apache-hive-4.0.0-alpha-2-bin
hdfs dfs -mkdir -p /user/hive/warehouse
hdfs dfs -chmod g+w /tmp
hdfs dfs -chmod g+w /user/hive/warehouse
bin/schematool -dbType postgres -initSchema
hive --hiveconf hive.server2.enable.doAs=false --hiveconf hive.security.authorization.enabled=false --service hiveserver2 &
