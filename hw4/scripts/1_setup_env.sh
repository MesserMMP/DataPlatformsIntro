
---

### ✅ `scripts/1_setup_env.sh`

```bash
#!/bin/bash
set -e

sudo apt update
sudo apt install -y python3-venv python3-pip

sudo -i -u hadoop bash <<EOF
cd ~
wget -nc https://archive.apache.org/dist/spark/spark-3.5.3/spark-3.5.3-bin-hadoop3.tgz
tar -xzf spark-3.5.3-bin-hadoop3.tgz

echo "Экспорт переменных..."
cat <<EOV >> ~/.bashrc
export HADOOP_CONF_DIR="/home/hadoop/hadoop-3.4.0/etc/hadoop"
export HIVE_HOME="/home/hadoop/apache-hive-4.0.0-alpha-2-bin"
export HIVE_CONF_DIR=\$HIVE_HOME/conf
export HIVE_AUX_JARS_PATH=\$HIVE_HOME/lib/*
export PATH=\$PATH:\$HIVE_HOME/bin
export SPARK_LOCAL_IP=192.168.1.14
export SPARK_DIST_CLASSPATH="/home/hadoop/spark-3.5.3-bin-hadoop3/jars/*:/home/hadoop/hadoop-3.4.0/etc/hadoop:/home/hadoop/hadoop-3.4.0/share/hadoop/common/lib/*:/home/hadoop/hadoop-3.4.0/share/hadoop/common/*:/home/hadoop/hadoop-3.4.0/share/hadoop/hdfs:/home/hadoop/hadoop-3.4.0/share/hadoop/hdfs/lib/*:/home/hadoop/hadoop-3.4.0/share/hadoop/mapreduce/*:/home/hadoop/hadoop-3.4.0/share/hadoop/yarn:/home/hadoop/hadoop-3.4.0/share/hadoop/yarn/lib/*:/home/hadoop/apache-hive-4.0.0-alpha-2-bin/*:/home/hadoop/apache-hive-4.0.0-alpha-2-bin/lib/*"
cd spark-3.5.3-bin-hadoop3
export SPARK_HOME=\$(pwd)
export PYTHONPATH=\$(ZIPS=(\$SPARK_HOME/python/lib/*.zip); IFS=:; echo "\${ZIPS[*]}"):\$PYTHONPATH
export PATH=\$SPARK_HOME/bin:\$PATH
EOV

source ~/.bashrc
EOF

echo "✅ Окружение готово"
