
# 📘 HW2: Развёртывание YARN и настройка веб-интерфейсов

## 🔐 Шаг 1: Подключение к кластеру

Подключитесь к главному узлу с вашего локального терминала:

```bash
ssh team@176.109.91.5
```

---

## 👤 Шаг 2: Переход в пользователя `hadoop` и вход на узел `tmpl-nn`

```bash
sudo -i -u hadoop
ssh tmpl-nn
```

---

## 🛠️ Шаг 3: Форматирование и запуск HDFS (если не сделано ранее)

```bash
hadoop-3.4.0/bin/hdfs namenode -format
hadoop-3.4.0/sbin/start-dfs.sh
```

---

## 🌐 Шаг 4: Настройка проброса порта и веб-интерфейса HDFS (порт 9870)

Создайте файл `/etc/nginx/sites-available/nn` со следующим содержимым:

```nginx
server {
 listen 9870;

 root /var/www/html;
 index index.html index.htm;

 server_name _;

 location / {
  proxy_pass http://tmpl-nn:9870;
 }
}
```

Активируйте конфигурацию и перезапустите `nginx`:

```bash
sudo ln -s /etc/nginx/sites-available/nn /etc/nginx/sites-enabled/nn
sudo systemctl reload nginx
```

На своей машине пробросьте порт:

```bash
ssh -L 9870:127.0.0.1:9870 team@176.109.91.5
```

---

## ⚙️ Шаг 5: Настройка YARN

На узле `tmpl-jn`:

```bash
cd hadoop-3.4.0/etc/hadoop/
```

Измените содержимое файла `yarn-site.xml`:

```xml
<configuration>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <property>
        <name>yarn.nodemanager.env-whitelist</name>
        <value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,PATH,LANG,TZ,HADOOP_MAPRED_HOME</value>
    </property>
    <property>
        <name>yarn.resourcemanager.hostname</name>
        <value>tmpl-nn</value>
    </property>
    <property>
        <name>yarn.resourcemanager.address</name>
        <value>tmpl-nn:8032</value>
    </property>
    <property>
        <name>yarn.resourcemanager.resource-tracker.address</name>
        <value>tmpl-nn:8031</value>
    </property>
</configuration>
```

Измените содержимое файла `mapred-site.xml`:

```xml
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
    <property>
        <name>mapreduce.application.classpath</name>
        <value>$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/mapreduce/lib/*</value>
    </property>
</configuration>
```

Скопируйте файлы на все узлы:

```bash
for node in tmpl-nn tmpl-dn-00 tmpl-dn-01; do
  scp yarn-site.xml mapred-site.xml $node:/home/hadoop/hadoop-3.4.0/etc/hadoop/
done
```

---

## ▶️ Шаг 6: Запуск YARN и History Server

На узле `tmpl-nn`:

```bash
hadoop-3.4.0/sbin/start-yarn.sh
mapred --daemon start historyserver
```

---

## 🌍 Шаг 7: Настройка веб-интерфейсов YARN (порт 8088) и History Server (порт 19888)

Создайте файлы `/etc/nginx/sites-available/ya` и `/etc/nginx/sites-available/dh`:

### Файл `/etc/nginx/sites-available/ya`

```nginx
server {
 listen 8088;

 root /var/www/html;
 index index.html index.htm;

 server_name _;

 location / {
  proxy_pass http://tmpl-nn:8088;
 }
}
```

### Файл `/etc/nginx/sites-available/dh`

```nginx
server {
 listen 19888;

 root /var/www/html;
 index index.html index.htm;

 server_name _;

 location / {
  proxy_pass http://tmpl-nn:19888;
 }
}
```

Активируйте и перезапустите `nginx`:

```bash
sudo ln -s /etc/nginx/sites-available/ya /etc/nginx/sites-enabled/ya
sudo ln -s /etc/nginx/sites-available/dh /etc/nginx/sites-enabled/dh
sudo systemctl reload nginx
```

---

## 🔁 Шаг 8: Проброс портов для веб-интерфейсов

На своей машине выполните:

```bash
ssh -L 9870:127.0.0.1:9870 -L 8088:127.0.0.1:8088 -L 19888:127.0.0.1:19888 team@176.109.91.5
```

---

## ✅ Результат

После выполнения всех шагов:

- Интерфейс HDFS доступен на [localhost:9870](http://localhost:9870)
- Интерфейс YARN — на [localhost:8088](http://localhost:8088)
- History Server — на [localhost:19888](http://localhost:19888)

---
