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
    df_cleaned = df.withColumn("Model Year", F.col("Model Year").cast("int"))  # Преобразование типов
    df_agg = df_cleaned.groupBy("Make").count().orderBy("count", ascending=False)  # Агрегация
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
