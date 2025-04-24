#!/bin/bash
set -e

sudo -i -u hadoop bash <<EOF
source ~/venv/bin/activate || python3 -m venv ~/venv && source ~/venv/bin/activate
pip install -U pip
pip install ipython onetl[files]

ipython <<PYCODE
from pyspark.sql import SparkSession, functions as F
from onetl.connection import SparkHDFS, Hive
from onetl.file import FileDFReader
from onetl.file.format import CSV
from onetl.db import DBWriter
from pyspark.sql.types import IntegerType, DoubleType

spark = SparkSession.builder \
    .master("yarn") \
    .appName("spark-with-yarn") \
    .config("spark.sql.warehouse.dir", "/user/hive/warehouse") \
    .config("spark.hive.metastore.uris", "thrift://tmpl-jn:9083") \
    .enableHiveSupport() \
    .getOrCreate()

hdfs = SparkHDFS(host="tmpl-nn", port=9000, spark=spark, cluster="test")
reader = FileDFReader(connection=hdfs, format=CSV(delimiter=",", header=True), source_path="/input")
df = reader.run(["electric_vehicles.csv"])

df_transformed = df \
    .withColumn("Model Year", F.col("Model Year").cast(IntegerType())) \
    .withColumn("Electric Range", F.col("Electric Range").cast(IntegerType())) \
    .withColumn("Base MSRP", F.col("Base MSRP").cast(DoubleType()))

writer1 = DBWriter(connection=Hive(spark=spark, cluster="test"), table="test.spark_auto", options={"if_exists": "replace_entire_table"})
writer1.run(df_transformed)

writer2 = DBWriter(connection=Hive(spark=spark, cluster="test"), table="test.spark_single_partition", options={"if_exists": "replace_entire_table"})
writer2.run(df_transformed.coalesce(1))

writer3 = DBWriter(connection=Hive(spark=spark, cluster="test"), table="test.hive_partitioned", options={"if_exists": "replace_entire_table", "partitionBy": "Model Year"})
writer3.run(df_transformed)

spark.stop()
PYCODE
EOF

echo "✅ Spark-задача выполнена и результаты сохранены в Hive"
