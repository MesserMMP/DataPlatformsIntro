#!/bin/bash
echo "[*] Копирование конфигураций Hadoop (core-site.xml, hdfs-site.xml)..."
CONFIG_DIR=~/hadoop-3.4.0/etc/hadoop
cat <<EOF > $CONFIG_DIR/core-site.xml
<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://tmpl-nn:9000</value>
  </property>
</configuration>
EOF
cat <<EOF > $CONFIG_DIR/hdfs-site.xml
<configuration>
  <property>
    <name>dfs.replication</name>
    <value>3</value>
  </property>
  <property>
    <name>dfs.namenode.name.dir</name>
    <value>file:/home/hadoop/hadoop-3.4.0/hdfs/namenode</value>
  </property>
  <property>
    <name>dfs.datanode.data.dir</name>
    <value>file:/home/hadoop/hadoop-3.4.0/hdfs/datanode</value>
  </property>
</configuration>
EOF
