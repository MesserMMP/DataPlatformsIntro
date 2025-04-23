#!/bin/bash
# Загрузка данных в Hive

wget https://huggingface.co/datasets/datasets-examples/doc-formats-tsv-3/resolve/main/data.tsv -O data.tsv
hdfs dfs -mkdir -p /test
hdfs dfs -put data.tsv /test

beeline -u jdbc:hive2://tmpl-jn:5432 -n scott -p tiger <<EOF
CREATE DATABASE IF NOT EXISTS test;
USE test;
CREATE TABLE IF NOT EXISTS animal_sounds (
    kind STRING,
    sound STRING
) COMMENT 'animal_sounds table'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t';
LOAD DATA INPATH '/test/data.tsv' INTO TABLE test.animal_sounds;
SELECT * FROM test.animal_sounds LIMIT 5;
EOF
