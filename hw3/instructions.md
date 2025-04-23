# 📘 HW3: Развёртывание Apache Hive

## 🗂 Структура задания

- **Цель:** Развёртывание Apache Hive (без embedded-режима) и демонстрация загрузки данных в таблицу Hive.
- **Результат:** Инструкция по настройке Hive с использованием PostgreSQL в качестве метастора и пример загрузки данных в таблицу.

---

## 🔐 Шаг 1: Подключение к кластеру

Подключитесь к главному узлу с вашего локального терминала:

```bash
ssh team@176.109.91.5
```

---

## 🛠️ Шаг 2: Установка PostgreSQL и создание Metastore

1. Перейдите на узел `tmpl-nn`:

    ```bash
    ssh tmpl-nn
    ```

2. Установите PostgreSQL, создайте пользователя и базу данных:

    ```bash
    sudo apt update
    sudo apt install postgresql -y
    sudo -i -u postgres
    psql
    ```

    В `psql` выполните:

    ```sql
    CREATE DATABASE metastore;
    CREATE USER hive WITH PASSWORD 'hiveMegaPass';
    GRANT ALL PRIVILEGES ON DATABASE "metastore" TO hive;
    ALTER DATABASE metastore OWNER TO hive;
    ```

3. Отредактируйте `postgresql.conf`:

    ```bash
    sudo vim /etc/postgresql/16/main/postgresql.conf
    ```

    Измените строки:

    ```text
    listen_addresses = 'tmpl-nn'
    port = 5433
    ```

4. Отредактируйте `pg_hba.conf`:

    ```bash
    sudo vim /etc/postgresql/16/main/pg_hba.conf
    ```

    Добавьте строки:

    ```text
    host    metastore       hive            192.168.1.1/32          password
    host    metastore       hive            192.168.1.14/32         password
    ```

5. Перезапустите PostgreSQL:

    ```bash
    sudo systemctl restart postgresql
    ```

---

## 🐝 Шаг 3: Установка Hive и настройка

1. Установите PostgreSQL клиент на `tmpl-jn`:

    ```bash
    sudo apt install postgresql-client-16
    ```

2. Скачайте и распакуйте Hive:

    ```bash
    wget https://archive.apache.org/dist/hive/hive-4.0.0-alpha-2/apache-hive-4.0.0-alpha-2-bin.tar.gz
    tar -xzvf apache-hive-4.0.0-alpha-2-bin.tar.gz
    ```

3. Установите JDBC-драйвер PostgreSQL:

    ```bash
    cd apache-hive-4.0.0-alpha-2-bin/lib/
    wget https://jdbc.postgresql.org/download/postgresql-42.7.4.jar
    ```

4. Настройте `hive-site.xml`:

    ```bash
    vim ../conf/hive-site.xml
    ```

    Добавьте следующее содержимое:

    ```xml
    <configuration>
        <property>
            <name>hive.server2.authentication</name>
            <value>NONE</value>
        </property>
        <property>
            <name>hive.metastore.warehouse.dir</name>
            <value>/user/hive/warehouse</value>
        </property>
        <property>
            <name>hive.server2.thrift.port</name>
            <value>5432</value>
        </property>
        <property>
            <name>javax.jdo.option.ConnectionURL</name>
            <value>jdbc:postgresql://tmpl-nn:5433/metastore</value>
        </property>
        <property>
            <name>javax.jdo.option.ConnectionDriverName</name>
            <value>org.postgresql.Driver</value>
        </property>
        <property>
            <name>javax.jdo.option.ConnectionUserName</name>
            <value>hive</value>
        </property>
        <property>
            <name>javax.jdo.option.ConnectionPassword</name>
            <value>hiveMegaPass</value>
        </property>
    </configuration>
    ```

5. Добавьте переменные окружения:

    ```bash
    vim ~/.profile
    ```

    ```bash
    export HIVE_HOME=/home/hadoop/apache-hive-4.0.0-alpha-2-bin
    export HIVE_CONF_DIR=$HIVE_HOME/conf
    export HIVE_AUX_JARS_PATH=$HIVE_HOME/lib/*
    export PATH=$PATH:$HIVE_HOME/bin
    ```

    Примените:

    ```bash
    source ~/.profile
    hive --version
    ```

---

## 📁 Шаг 4: Подготовка HDFS

1. Убедитесь, что папка `/tmp` существует:

    ```bash
    hdfs dfs -ls /
    ```

2. Создайте каталог `warehouse` и выдать права:

    ```bash
    hdfs dfs -mkdir -p /user/hive/warehouse
    hdfs dfs -chmod g+w /tmp
    hdfs dfs -chmod g+w /user/hive/warehouse
    ```

---

## 🏗️ Шаг 5: Инициализация Hive и запуск

1. Инициализируйте схему `Hive`:

    ```bash
    cd ~/apache-hive-4.0.0-alpha-2-bin
    bin/schematool -dbType postgres -initSchema
    ```

2. Запустите `HiveServer2`:

    ```bash
    hive --hiveconf hive.server2.enable.doAs=false \
         --hiveconf hive.security.authorization.enabled=false \
         --service hiveserver2 1>> /tmp/hs2.log 2>> /tmp/hs2.log &
    ```

3. Подключитесь через `beeline`:

    ```bash
    beeline -u jdbc:hive2://tmpl-jn:5432 -n scott -p tiger
    ```

---

## 📊 Шаг 6: Загрузка данных

1. Скачайте данные и положите их в HDFS:

    ```bash
    cd ~
    wget https://huggingface.co/datasets/datasets-examples/doc-formats-tsv-3/resolve/main/data.tsv
    hdfs dfs -put data.tsv /test
    ```

2. Создайте базу и таблицу:

    ```sql
    CREATE DATABASE test;
    CREATE TABLE IF NOT EXISTS test.animal_sounds (
        kind STRING,
        sound STRING)
        COMMENT 'animal_sounds table'
        ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t';
    ```

3. Загрузите данные:

    ```sql
    USE test;
    LOAD DATA INPATH '/test/data.tsv' INTO TABLE test.animal_sounds;
    SELECT * FROM test.animal_sounds LIMIT 5;
    ```

---
