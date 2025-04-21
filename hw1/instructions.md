# HW1: Развёртывание HDFS-кластера

## 🧾 Цель

Развернуть HDFS-кластер, состоящий из:
- **1 NameNode**
- **1 Secondary NameNode**
- **3 DataNode**

---

## 🔐 Шаг 1: Подключение к среде

Подключаемся к главному узлу:

```bash
ssh team@176.109.91.5
```

---

## 🗝️ Шаг 2: Настройка SSH-доступа между узлами

### Генерация ключа:

```bash
ssh-keygen
cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
```

### Распространение ключа на остальные узлы:

```bash
scp ~/.ssh/authorized_keys 192.168.1.15:/home/team/.ssh/
scp ~/.ssh/authorized_keys 192.168.1.16:/home/team/.ssh/
scp ~/.ssh/authorized_keys 192.168.1.17:/home/team/.ssh/
```

---

## 🧭 Шаг 3: Настройка `/etc/hosts` на всех узлах

### Содержимое файла для узла `jn`
```txt
# 127.0.0.1 localhost
127.0.0.1 tmpl-jn

192.168.1.15 tmpl-nn
192.168.1.16 tmpl-dn-00
192.168.1.17 tmpl-dn-01
```

### Содержимое файла для узла `nn`
```txt
# 127.0.0.1 localhost

192.168.1.14 tmpl-jn
192.168.1.15 tmpl-nn
192.168.1.16 tmpl-dn-00
192.168.1.17 tmpl-dn-01
```

### Содержимое файла для узла `dn-00`
```txt
# 127.0.0.1 localhost
127.0.0.1 tmpl-dn-00

192.168.1.14 tmpl-jn
192.168.1.15 tmpl-nn
192.168.1.17 tmpl-dn-01
```
### Содержимое файла для узла `dn-01`
```txt
# 127.0.0.1 localhost
127.0.0.1 tmpl-dn-01

192.168.1.14 tmpl-jn
192.168.1.15 tmpl-nn
192.168.1.16 tmpl-dn-00
```

---

## 👤 Шаг 4: Создание пользователя `hadoop`

На **всех узлах**:

```bash
sudo adduser hadoop
```

**Данные для входа:**

```json
"user": "hadoop",
"password": "hadooppass1"
```

---

## 🔁 Шаг 5: Повторная настройка SSH-доступа от `hadoop`

Чтобы пользователь hadoop мог заходить на другие узлы от своего имени, повторим операцию с генерацией ключа и его распространением на все остальные узлы:

```bash
sudo -i -u hadoop
ssh-keygen
cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
scp -r ~/.ssh tmpl-nn:/home/hadoop
scp -r ~/.ssh tmpl-dn-00:/home/hadoop
scp -r ~/.ssh tmpl-dn-01:/home/hadoop
```

---

## 🧩 Шаг 6: Установка Hadoop

```bash
wget https://dlcdn.apache.org/hadoop/common/hadoop-3.4.0/hadoop-3.4.0.tar.gz
```

### Распределить архив по узлам:

```bash
scp hadoop-3.4.0.tar.gz tmpl-nn:/home/hadoop
scp hadoop-3.4.0.tar.gz tmpl-dn-00:/home/hadoop
scp hadoop-3.4.0.tar.gz tmpl-dn-01:/home/hadoop
```

### Распаковать скачанный дистрибутив на всех узлах:

```bash
tar -xzvf hadoop-3.4.0.tar.gz
```

---

## ⚙️ Шаг 7: Настройка переменных окружения

Убедиться, что у установлена версия Java, совместимая с Hadoop. Посмотреть, где находится бинарный файл:
```bash
which java
readlink -f /usr/bin/java
```

Добавить в `~/.profile`:

```bash
export HADOOP_HOME=/home/hadoop/hadoop-3.4.0
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
```

Активировать:

```bash
source ~/.profile
```

Скопировать на другие узлы:

```bash
scp ~/.profile tmpl-nn:/home/hadoop
scp ~/.profile tmpl-dn-00:/home/hadoop
scp ~/.profile tmpl-dn-01:/home/hadoop
```

---

## 🧾 Шаг 8: Конфигурация Hadoop

Перейти в директорию:

```bash
cd hadoop-3.4.0/etc/hadoop
```

### `hadoop-env.sh`

```bash
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
```

### `core-site.xml`

```xml
<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://tmpl-nn:9000</value>
  </property>
</configuration>
```

### `hdfs-site.xml`

```xml
<configuration>
  <property>
    <name>dfs.replication</name>
    <value>3</value>
  </property>
</configuration>
```

### `workers`

```txt
tmpl-nn
tmpl-dn-00
tmpl-dn-01
```

### Распространение конфигов

```bash
for file in hadoop-env.sh core-site.xml hdfs-site.xml workers; do
  scp $file tmpl-nn:/home/hadoop/hadoop-3.4.0/etc/hadoop
  scp $file tmpl-dn-00:/home/hadoop/hadoop-3.4.0/etc/hadoop
  scp $file tmpl-dn-01:/home/hadoop/hadoop-3.4.0/etc/hadoop
done
```

---

## 📛 Шаг 9: Настройка имён хостов

На каждом узле:

```bash
sudo vim /etc/hostname
```

Установить:

- `tmpl-jn`
- `tmpl-nn`
- `tmpl-dn-00`
- `tmpl-dn-01`

Перезагрузка системы:

```bash
sudo shutdown -r now
```

---

## 🚀 Шаг 10: Запуск кластера

На `tmpl-nn` под `hadoop`:

```bash
cd ~/hadoop-3.4.0
bin/hdfs namenode -format
sbin/start-dfs.sh
```

---

## 🛑 Остановка кластера

```bash
sbin/stop-dfs.sh
```

---
