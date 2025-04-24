# 📘 HW4: Развертывание Apache Spark с YARN и интеграция с HDFS + Hive

## 📋 Описание задания

Реализация использования Apache Spark под управлением YARN на кластере, настроенном в предыдущих заданиях. Работа включает чтение, трансформацию и сохранение данных в Hive, с использованием партиционирования и возможностью чтения через Hive CLI.

---

## 🧰 Предварительные требования

- Ubuntu 24.04
- Python 3.12.3
- Java 11.0.26
- Развернутый кластер HDFS
- Развернутый Hive Metastore

---

## 🔐 Шаг 1. Подключение к главному узлу (Jump Node)

```bash
ssh -L 9870:127.0.0.1:9870 -L 8088:127.0.0.1:8088 -L 19888:127.0.0.1:19888 team@<JUMP-HOST-IP>
```

Замените `<JUMP-HOST-IP>` на IP-адрес вашей jump-ноды.

---

## ⚙️ Шаг 2. Установка и настройка окружения

### Установка зависимостей:

```bash
sudo apt update
sudo apt install python3-venv python3-pip
```

### Переход в пользователя Hadoop:

```bash
sudo -i -u hadoop
```

### Скачивание и установка Apache Spark:

```bash
wget https://archive.apache.org/dist/spark/spark-3.5.3/spark-3.5.3-bin-hadoop3.tgz
tar -xzvf spark-3.5.3-bin-hadoop3.tgz
```

---

## 🌍 Шаг 3. Настройка переменных окружения

```bash
export HADOOP_CONF_DIR="/home/hadoop/hadoop-3.4.0/etc/hadoop"
export HIVE_HOME="/home/apache-hive-4.0.1-bin"
export HIVE_CONF_DIR=$HIVE_HOME/conf
export HIVE_AUX_JARS_PATH=$HIVE_HOME/lib/*
export PATH=$PATH:$HIVE_HOME/bin
export SPARK_LOCAL_IP=192.168.1.14 # Укажите IP вашей jump-ноды
export SPARK_DIST_CLASSPATH="/home/hadoop/spark-3.5.3-bin-hadoop3/jars/*:/home/hadoop/hadoop-3.4.0/etc/hadoop:/home/hadoop/hadoop-3.4.0/share/hadoop/common/lib/*:/home/hadoop/hadoop-3.4.0/share/hadoop/common/*:/home/hadoop/hadoop-3.4.0/share/hadoop/hdfs:/home/hadoop/hadoop-3.4.0/share/hadoop/hdfs/lib/*:/home/hadoop/hadoop-3.4.0/share/hadoop/hdfs/*:/home/hadoop/hadoop-3.4.0/share/hadoop/mapreduce/*:/home/hadoop/hadoop-3.4.0/share/hadoop/yarn:/home/hadoop/hadoop-3.4.0/share/hadoop/yarn/lib/*:/home/hadoop/hadoop-3.4.0/share/hadoop/yarn/*:/home/hadoop/apache-hive-4.0.0-alpha-2-bin/*:/home/hadoop/apache-hive-4.0.0-alpha-2-bin/lib/*"
cd spark-3.5.3-bin-hadoop3/
export SPARK_HOME=`pwd`
export PYTHONPATH=$(ZIPS=("$SPARK_HOME"/python/lib/*.zip); IFS=:; echo "${ZIPS[*]}"):$PYTHONPATH
export PATH=$SPARK_HOME/bin:$PATH
```

---

## 🧪 Шаг 4. Подготовка Python окружения

```bash
cd ~
python3 -m venv venv
source venv/bin/activate

pip install -U pip
pip install ipython
pip install onetl[files]
```

---

## 📂 Шаг 5. Подготовка данных в HDFS

```bash
hdfs dfs -mkdir -p /input
wget <ССЫЛКА_НА_ДАННЫЕ> -O for_spark.csv
hdfs dfs -put for_spark.csv /input
```

---

## 🚀 Шаг 6. Запуск Spark-сессии с Hive и YARN

```bash
ipython
```

### 📦 Чтение данных и подключение к HDFS:

```python
from pyspark.sql import SparkSession, functions as F
from onetl.connection import SparkHDFS, Hive
from onetl.file import FileDFReader
from onetl.file.format import CSV
from onetl.db import DBWriter

spark = SparkSession.builder \
    .master("yarn") \
    .appName("spark-with-yarn") \
    .config("spark.sql.warehouse.dir", "/user/hive/warehouse") \
    .config("spark.hive.metastore.uris", "thrift://tmpl-jn:9083") \
    .enableHiveSupport() \
    .getOrCreate()

hdfs = SparkHDFS(host="tmpl-nn", port=9000, spark=spark, cluster="test")
reader = FileDFReader(connection=hdfs, format=CSV(delimiter=",", header=True), source_path="/input")
df = reader.run(["for_spark.csv"])
df.count() # Общее число строк
df.rdd.getNumPartitions() # Число партиций
```

---

## 🔁 Шаг 7. Трансформация и партиционирование

Добавим колонку `reg_year` для партиционирования:

```python
df = df.withColumn("reg_year", F.col("registration date").substr(0, 4))
df.select("reg_year").distinct().show() # Показываем уникальные значения в столбце партиционирования
```

---

## 📝 Шаг 8. Запись данных в Hive тремя способами

### ✅ Способ 1. Автоматическая запись через Spark без явного указания партиций

Создаём таблицу `test.spark_auto`:

```python
from onetl.db import DBWriter
from onetl.connection import Hive

hive = Hive(spark=spark, cluster="test")
hive.check()  # Проверка подключения

writer = DBWriter(
    connection=hive,
    table="test.spark_auto",
    options={"if_exists": "replace_entire_table"},
)
writer.run(df)
```

---

### ✅ Способ 2. Объединение всех партиций Spark в одну (coalesce)

Создаём таблицу `test.spark_single_partition`:

```python
df_single_partition = df.coalesce(1)

writer = DBWriter(
    connection=hive,
    table="test.spark_single_partition",
    options={"if_exists": "replace_entire_table"},
)
writer.run(df_single_partition)
```

---

### ✅ Способ 3. Партиционирование через Hive по столбцу `reg_year`

Создаём таблицу `test.hive_partitioned`:

```python
writer = DBWriter(
    connection=hive,
    table="test.hive_partitioned",
    options={
        "if_exists": "replace_entire_table",
        "partitionBy": "reg_year",
    },
)
writer.run(df)
```

---

## 🔍 Шаг 9. Проверка результатов в Hive CLI

```sql
hive
> USE test;
> SHOW TABLES;
> SELECT COUNT(*) FROM spark_auto;
> SELECT COUNT(*) FROM spark_single_partition;
> SELECT reg_year, COUNT(*) FROM hive_partitioned GROUP BY reg_year;
```

---

## ⛔ Шаг 10. Завершение сессии

```python
spark.stop()
```

---
