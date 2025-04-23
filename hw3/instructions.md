# 📘 HW3: Развёртывание Apache Hive

## 🔐 Шаг 1: Подключение к кластеру

Подключитесь к главному узлу с вашего локального терминала:

```bash
ssh team@176.109.91.5
```

---

## Шаг 2: Установка postgresql и далее

Перейдите на узел `tmpl-nn` и установите `postgresql`:
```bash
ssh tmpl-nn
```

Теперь переключитесь в пользователя `postgres`:
```bash
sudo -i -u postgres
```

Создайте базу данных `metastore`, пользователя `hive` и дайте ему все привилегии:
```bash
psql
```

```sql
CREATE DATABASE metastore;
CREATE USER hive with password 'hiveMegaPass';
GRANT ALL PRIVILEGES ON DATABASE "metastore" to hive;
ALTER DATABASE metastore OWNER TO hive;
```

Подкорректируем конфиг, чтобы к нему можно было подключаться извне. Для этого изменим файл `/etc/postgresql/16/main/postgresql.conf`:

Укажите имя хоста, который он будет слушать и измените порт на 5433:
```txt
listen_addresses = 'tmpl-nn'
port=5433
```

А в файл `sudo vim /etc/postgresql/16/main/pg_hba.conf` добавьте строки:
```txt
host    metastore       hive            192.168.1.1/32          password
host    metastore       hive            192.168.1.14/32         password
```
Вместо 192.168.1.14 нужно написать ip-адрес jump ноды.

Перезапустите postgres:
```bash
sudo systemctl restart postgresql
```

Вернитесь на `jn` и установите клиента для `postgres`:
```bash
sudo apt install postgresql-client-16
```

Проверьте подключение к БД:
```bash
psql -h tmpl-nn -p 5433 -U hive -W -d metastore
```

Перейдите в пользователя `hadoop`:

```bash
sudo -i -u hadoop
```

Cкачайте и распакуйте дистрибутив `hive`:

```bash
wget https://archive.apache.org/dist/hive/hive-4.0.0-alpha-2/apache-hive-4.0.0-alpha-2-bin.tar.gz
tar -xzvf apache-hive-4.0.0-alpha-2-bin.tar.gz
```

Перейдите в папку `apache-hive-4.0.0-alpha-2-bin/lib/` и установите драйвер для `postgres`:
```bash
cd apache-hive-4.0.0-alpha-2-bin/lib/
wget https://jdbc.postgresql.org/download/postgresql-42.7.4.jar
```
Отредактируйте конфиги:
```bash
vim ../conf/hive-site.xml
```
Cодержимое файла `hive-site.xml`:

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
Добавьте переменные окружения в профиль:

```bash
vim ~/.profile
```

```txt
export HIVE_HOME=/home/hadoop/apache-hive-4.0.0-alpha-2-bin
export HIVE_CONF_DIR=$HIVE_HOME/conf
export HIVE_AUX_JARS_PATH=$HIVE_HOME/lib/*
export PATH=$PATH:$HIVE_HOME/bin
```

Примените переменные окружения и убедитесь, что все работает:
```bash
source ~/.profile
hive --version
```

Убедитесь, что папка для временных файлов `tmp` существует - ее можно будет увидеть в списке:
```bash
hdfs dfs -ls /
```

Создайте папку для DWH:
```bash
hdfs dfs -mkdir -p /user/hive/warehouse
```

Выдайте права этим папкам:
```bash
hdfs dfs -chmod g+w /tmp
hdfs dfs -chmod g+w /user/hive/warehouse
```

Инициализируйте внутреннюю базу данных `hive`.
```bash
cd ~/apache-hive-4.0.0-alpha-2-bin
bin/schematool -dbType postgres -initSchema
```

Запустите `hive` с помощью такой команды:
```bash
hive --hiveconf hive.server2.enable.doAs=false --hiveconf hive.security.authorization.enabled=false --service hiveserver2 1>> /tmp/hs2.log 2>> /tmp/hs2.log &
```

Можно подключиться:
```bash
beeline -u jdbc:hive2://tmpl-jn:5432 -n scott -p tiger
```

## Пример загрузки данных

Перейдите в домашнюю директорию и скачайте для примера файл `data.tsv`:
```bash
cd ~
wget [https://huggingface.co/datasets/datasets-examples/doc-formats-tsv-3/resolve/main/data.tsv](https://huggingface.co/datasets/datasets-examples/doc-formats-tsv-3/resolve/main/data.tsv)
```

Положите файл `data.tsv` на файловую систему: 
```bash
hdfs dfs -put data.tsv /test
```

Из него сделайте таблицу:
```bash
beeline -u jdbc:hive2://tmpl-jn:5432 -n scott -p tiger
```

Создадайте базу данных `test`:
```sql
CREATE DATABASE test;
```

Создадайте таблицу:
```sql
CREATE TABLE IF NOT EXISTS test.animal_sounds (
    kind STRING,
    sound STRING)
    COMMENT 'animal_sounds table'
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t';
```

Подключитесь к созданной базе данных и заполним таблицу данными: 
```sql
USE test;
LOAD DATA INPATH '/test/data.tsv' INTO TABLE test.animal_sounds;
```

Проверьте, что данные были успешно добавлены:
```sql
SELECT * FROM test.animal_sounds LIMIT 5;
```

---
