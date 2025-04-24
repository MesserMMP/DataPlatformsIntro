# 🚀 HW5: Data Processing Flow with Prefect + Apache Spark on YARN

## 🔐 Шаг 1. Подключение к главному узлу (Jump Node) и вход в пользователя `hadoop`

```bash
ssh -L 9870:127.0.0.1:9870 -L 8088:127.0.0.1:8088 -L 19888:127.0.0.1:19888 team@<JUMP-HOST-IP>
sudo -i -u hadoop
```
Замените `<JUMP-HOST-IP>` на IP-адрес вашей jump-ноды.

## Остальные шаги

## 🧪 Шаг 4. Подготовка Python окружения

```bash
cd ~
python3 -m venv venv
source venv/bin/activate
pip install prefect
```

Создайте скрипт для `prefect` - `etl_flow.py`:
```bash
vim etl_flow.py
```
`etl_flow.py`:
```python
from pyspark.sql import SparkSession, functions as F
from onetl.connection import SparkHDFS, Hive
from onetl.file import FileDFReader
from onetl.file.format import CSV
from onetl.db import DBWriter
from prefect import flow, task

@task
def get_spark():
    spark = SparkSession.builder \
        .master("yarn") \
        .appName("spark-with-yarn") \
        .config("spark.sql.warehouse.dir", "/user/hive/warehouse") \
        .config("spark.hive.metastore.uris", "thrift://tmpl-jn:9083") \
        .enableHiveSupport() \
        .getOrCreate()
    return spark


@task
def stop_spark(spark):
    spark.stop()


@task
def extract(spark):
    hdfs = SparkHDFS(host="tmpl-nn", port=9000, spark=spark, cluster="test")
    reader = FileDFReader(connection=hdfs, format=CSV(delimiter=",", header=True), source_path="/input")
    df = reader.run(["electric_vehicles.csv"])
    return df


@task
def transform(df):
    df_cleaned = df.withColumn("Model Year", F.col("Model Year").cast("int")) # Трансформация типов
    df_agg = df_cleaned.groupBy("Make").count().orderBy("count", ascending=False) # Агрегация
    return df_agg


@task
def load(spark, df):
    hive = Hive(spark=spark, cluster="test")
    writer = DBWriter(connection=hive, table="test.ev_aggregated_counts",
                      options={"if_exists": "replace_entire_table"})
    writer.run(df)


@flow
def process_data():
    spark = get_spark()
    df = extract(spark)
    df = transform(df)
    load(spark, df)
    stop_spark(spark)


if __name__ == "__main__":
    process_data()
```
 Запустите скрипт
```bash
python etl_flow.py
```

*Появилась новая таблица ev_aggregated_counts:*

![All_tables](./screenshots/all_tables.png)

## 🔍 Шаг 9. Проверка результатов в Hive CLI


```bash
beeline -u jdbc:hive2://tmpl-jn:5432 -n scott -p tiger
```

Сделайте `sql` запрос для проверки:
```sql
USE test;
SHOW TABLES;
SELECT * FROM ev_aggregated_counts LIMIT 10;
```

*Таблица содержит верные данные:*

![sql_results](./screenshots/sql_results.png)

---

