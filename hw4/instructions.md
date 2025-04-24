# 📘 HW4: Реализация Apache Spark под управлением YARN


## 🛠️ Предустановки

- Убедитесь, что у вас у вас установлена версия Java, совместимая со `Spark`
- Убедитесь, что объявлена переменная окружения `HADOOP_HOME` и она указывает на `Hadoop`
- Убедитесь, что в `PATH` добавлены исполняемые файлы дистрибутива `Hadoop`


## 🔐 Шаг 1: Подключение к кластеру

Подключитесь к главному узлу с вашего локального терминала, прокинув порты:

```bash
ssh -L 9870:127.0.0.1:9870 -L 8088:127.0.0.1:8088 -L 19888:127.0.0.1:19888 team@176.109.91.5
```

---


Установите `python-venv` и `python-pip` и `IPython`:

```bash
sudo apt install python3-venv
sudo apt install python3-pip
```

## 👤 Шаг 2: Переход в пользователя `hadoop` и далее

```bash
sudo -i -u hadoop
```

Установите и разархивируйте дистрибутив `Spark`:
```bash
wget https://archive.apache.org/dist/spark/spark-3.5.3/spark-3.5.3-bin-hadoop3.tgz
tar -xzvf spark-3.5.3-bin-hadoop3.tgz
```
## Подготовка среды для работы со `Spark`

Объявите ряд переменных, для `SPARK_LOCAL_IP` укажите локальный ip-адрес jump-ноды: 

```bash
export HADOOP_CONF_DIR="/home/hadoop/hadoop-3.4.0/etc/hadoop"
export HIVE_HOME="/home/apache-hive-4.0.1-bin"
export HIVE_CONF_DIR=$HIVE_HOME/conf
export HIVE_AUX_JARS_PATH=$HIVE_HOME/lib/*
export PATH=$PATH:$HIVE_HOME/bin
export SPARK_LOCAL_IP=192.168.1.14
export SPARK_DIST_CLASSPATH="/home/hadoop/spark-3.5.3-bin-hadoop3/jars/*:/home/hadoop/hadoop-3.4.0/etc/hadoop:/home/hadoop/hadoop-3.4.0/share/hadoop/common/lib/*:/home/hadoop/hadoop-3.4.0/share/hadoop/common/*:/home/hadoop/hadoop-3.4.0/share/hadoop/hdfs:/home/hadoop/hadoop-3.4.0/share/hadoop/hdfs/lib/*:/home/hadoop/hadoop-3.4.0/share/hadoop/hdfs/*:/home/hadoop/hadoop-3.4.0/share/hadoop/mapreduce/*:/home/hadoop/hadoop-3.4.0/share/hadoop/yarn:/home/hadoop/hadoop-3.4.0/share/hadoop/yarn/lib/*:/home/hadoop/hadoop-3.4.0/share/hadoop/yarn/*:/home/hadoop/apache-hive-4.0.0-alpha-2-bin/*:/home/hadoop/apache-hive-4.0.0-alpha-2-bin/lib/*"
cd spark-3.5.3-bin-hadoop3/
export SPARK_HOME=`pwd`
export PYTHONPATH=$(ZIPS=("$SPARK_HOME"/python/lib/*.zip); IFS=:; echo "${ZIPS[*]}"):$PYTHONPATH
export PATH=$SPARK_HOME/bin:$PATH
```

Вернитесь в домашнюю директорию и создадим новое виртуальное оркружение:
```bash
cd ~
python3 -m venv venv
source venv/bin/activate
```

Обновите `pip`, установите `IPython` и `onetl[files]`:
```bash
pip install -U pip
pip install ipython
pip install onetl[files]
```

В файловой системе `hadoop` создайте папку `input` и положите туда данные для работы со `Spark` в формате `.csv`:
```bash
hdfs dfs -mkdir -p /input
# Вместо ... укажите ссылку для скачивания данных
wget ... 
hdfs dfs -put for_spark.csv /input
```

Теперь запустите сессию `Spark`, чтобы преобразовать этот `.csv` файл в таблицу, описанную с помощью `hive`:
```bash
ipython
```

```python
from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from onetl.connection import SparkHDFS
from onetl.connection import Hive
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
hdfs.check()
reader = FileDFReader(connection=hdfs, format=CSV(delimiter=",", header=True), source_path="/input")
df = reader.run(["for_spark.csv"]) # Читаем данные, результат - дата фрейм
df.count() # Общее число строк
df.rdd.getNumPartitions() # Число партиций
```
Создайте столбец для дальнейшего партиционирования и добавьте его в дата фрейм
```python
dt = df.select("registrstion date")
dt.show()
df = df.withColumn("reg_year", F.col("registrstion date").substr(0, 4))
dt = df.select("reg_year")
dt.show()
```

Запишите данные как таблицу:
```python
hive = Hive(spark=spark, cluster="test")
hive.check() # Проверяем подключение
writer = DBWriter(connection=hive, table="test.spark_parts", options={"if_exists": "replace_entire_table"})
writer.run(df)
# writer.run(df.coalesce(1)) # Склеивает все партиции Spark в 1
```

Пример партиционирования через `Hive`
```python
hive = Hive(spark=spark, cluster="test")
hive.check() # Проверяем подключение
writer = DBWriter(connection=hive, table="test.hive_parts", options={"if_exists": "replace_entire_table", "partitionBy": "reg_year"}) # reg_year - столбец, по которому происходит партиционирование
writer.run(df)
```

Остановка сессии
```python
spark.stop()
quit()
```
