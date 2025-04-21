# HW1: Развёртывание HDFS-кластера


Через терминал подключимся к узлу

```bash
ssh team@176.109.91.5
```

Разложим ssh ключ пользователя по всем узлам

Сгенерируем новый ключ:

```bash
ssh-keygen
```

Добавим ключ в число авторизованных:
```bash
cat .ssh/id_ed25519.pub >> .ssh/authorized_keys
```

Распространим ключ по всем узлам:
```bash
scp .ssh/authorized_keys 192.168.1.15:/home/team/.ssh/
scp .ssh/authorized_keys 192.168.1.16:/home/team/.ssh/
scp .ssh/authorized_keys 192.168.1.17:/home/team/.ssh/
```

Сделаем, чтобы узлы откликались по определенным именам. Для этого изменим файл hosts:
```bash
sudo vim /etc/hosts
```

Содержимое файла hosts на jn:
```txt
# 127.0.0.1 localhost
127.0.0.1 tmpl-jn

192.168.1.15 tmpl-nn
192.168.1.16 tmpl-dn-00
192.168.1.17 tmpl-dn-01
```

Добавим пользователя, от имени которого будут выполняться серивисы Hadoop:
```bash
sudo adduser hadoop
```
```json
"user": "hadoop"
"password": "hadooppass1"
```

Добавим пользователя и изменим hosts аналогично на остальных узлах, подключаясь через ssh:

Содержимое файла hosts на nn:
```txt
# 127.0.0.1 localhost

192.168.1.14 tmpl-jn
192.168.1.15 tmpl-nn
192.168.1.16 tmpl-dn-00
192.168.1.17 tmpl-dn-01
```
Содержимое файла hosts на dn-00:
```txt
# 127.0.0.1 localhost
127.0.0.1 tmpl-dn-00

192.168.1.14 tmpl-jn
192.168.1.15 tmpl-nn
192.168.1.17 tmpl-dn-01
```
Содержимое файла hosts на dn-01:
```txt
# 127.0.0.1 localhost
127.0.0.1 tmpl-dn-01

192.168.1.14 tmpl-jn
192.168.1.15 tmpl-nn
192.168.1.16 tmpl-dn-00
```

Вернемся на jn и переключимся на созданного пользователя:
```bash
sudo -i -u hadoop
```

Чтобы пользователь hadoop мог заходить на другие узлы от своего имени, повторим операцию с генерацией ключа и его распространением на все остальные узлы.
```bash
ssh-keygen
cat .ssh/id_ed25519.pub >> .ssh/authorized_keys
scp -r .ssh/ tmpl-nn:/home/hadoop
scp -r .ssh/ tmpl-dn-00:/home/hadoop
scp -r .ssh/ tmpl-dn-01:/home/hadoop
```

Скачаем дистрибутив с Hadoop:
```bash
wget https://dlcdn.apache.org/hadoop/common/hadoop-3.4.0/hadoop-3.4.0.tar.gz
```

Разложим его на все узлы:
```bash
scp hadoop-3.4.0.tar.gz tmpl-nn:/home/hadoop
scp hadoop-3.4.0.tar.gz tmpl-dn-00:/home/hadoop
scp hadoop-3.4.0.tar.gz tmpl-dn-01:/home/hadoop
```

Распакуем скачанный дистрибутив на всех узлах:
```bash
tar -xzvf hadoop-3.4.0.tar.gz
```

Убедимся, что у нас установлена версия Java, совместимая с Hadoop (на данных нам виртуальных машинах - это Java 11, Hadoop способен с ней работать).
Посмотрим, где находится бинарный файл:

```bash
which java
readlink -f /usr/bin/java
```

Настроим профиль, добавив несколько переменных окружения в `.profile`:
```txt
export HADOOP_HOME=/home/hadoop/hadoop-3.4.0
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
```
Активируем команды:
```bash
source .profile
```

Раскидаем `.profile` на остальные узлы:
```bash
scp .profile tmpl-nn:/home/hadoop
scp .profile tmpl-dn-00:/home/hadoop
scp .profile tmpl-dn-01:/home/hadoop
```

Поправим конфиги в дистрибутиве. Для этого перейдем в папку с hadoop:
```bash
hadoop-3.4.0/etc/hadoop/
```

В файл `hadoop-env.sh` добавим путь к java:
```txt
JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
```

В файл `core-site.xml` добавим следующие строки:
```txt
<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://tmpl-nn:9000</value>
  </property>
</configuration>
```

В файл `hdfs-site.xml` добавим следующие строки:
```txt
<configuration>
  <property>
    <name>dfs.replication</name>
    <value>3</value>
  </property>
</configuration>
```

Поправим файл workers, укажем имена узлов, на которых должны быть запущены сервисы дата ноды:
```txt
tmpl-nn
tmpl-dn-00
tmpl-dn-01
```

Распространим на все остальные узлы:
```bash
scp hadoop-env.sh tmpl-nn:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp hadoop-env.sh tmpl-dn-00:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp hadoop-env.sh tmpl-dn-01:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp core-site.xml tmpl-nn:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp core-site.xml tmpl-dn-00:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp core-site.xml tmpl-dn-01:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp hdfs-site.xml tmpl-nn:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp hdfs-site.xml tmpl-dn-00:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp hdfs-site.xml tmpl-dn-01:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp workers tmpl-dn-01:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp workers tmpl-dn-00:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp workers tmpl-dn-01:/home/hadoop/hadoop-3.4.0/etc/hadoop
```

Вернемся к пользователю team и поправим имя хоста в файле `/etc/hostname`:
Для jn содержимое hostname:
```txt
tmpl-jn
```
Для nn содержимое hostname:
```txt
tmpl-nn
```
Для dn-00 содержимое hostname:
```txt
tmpl-dn-00
```
Для dn-01 содержимое hostname:
```txt
tmpl-dn-01
```

Перезапустим систему на каждом узле:
```bash
sudo shutdown -r now
```

Снова переключимся на пользователя hadoop:
```bash
sudo -i -u hadoop
```

Для запуска Hadoop подключимся к нейм-ноде:

```bash
ssh tmpl-nn
```

Создадим и отформатируем файловую систему:
```bash
cd hadoop-3.4.0/
bin/hdfs namenode -format
```

Запустим кластер Hadoop:
```bash
sbin/start-dfs.sh
```

Остановить работу кластера можно с помощью команды:
```bash
sbin/stop-dfs.sh
```
