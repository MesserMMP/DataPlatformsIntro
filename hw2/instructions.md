# HW2: Развёртывание  YARN

## 🔐 Шаг 1: Подключение к среде

Подключаемся к главному узлу:

```bash
ssh team@176.109.91.5
```

---

## Остальные шаги: 

Зайдем в пользователя hadoop и переключимся на узел  `nn`:
```bash
sudo -i -u hadoop
ssh tmpl-nn
```


Создадим файловую систему и запустим ее:
```bash
hadoop-3.4.0/bin/hdfs namenode -format
hadoop-3.4.0/sbin/start-dfs.sh
```

Для работы с web-интерфейсом создадим файл `/etc/nginx/sites-available/nn` с таким содержанием:

```nginx
server {
 listen 9870;


 root /var/www/html;

 # Add index.php to the list if you are using PHP
 index index.html index.htm index.nginx-debian.html;

 server_name _;

 location / {
  proxy_pass http://tmpl-nn:9870;
 }
}
```
Сделаем конфигурацию активной:

```bash
sudo ln -s /etc/nginx/sites-available/nn /etc/nginx/sites-enabled/nn
sudo systemctl reload nginx
```

Для проброски портов через локальный терминал выполним команду:
```bash
ssh -L 9870:127.0.0.1:9870 team@176.109.91.5
```

## YARN

Подключаемся к главному узлу, зайдем в пользователя hadoop и перейдем в папку `hadoop-3.4.0/etc/hadoop/`:

```bash
ssh team@176.109.91.5
sudo -i -u hadoop
cd hadoop-3.4.0/etc/hadoop/
```

Изменим содердимое файла `yarn-site.xml`:

```xml
<configuration>
<!-- Site specific YARN configuration properties -->
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

Изменим содердимое файла `mapred-site.xml`:
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

Скопируем их на остальные узлы:
```bash
scp yarn-site.xml tmpl-nn:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp yarn-site.xml tmpl-dn-00:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp yarn-site.xml tmpl-dn-01:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp mapred-site.xml tmpl-nn:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp mapred-site.xml tmpl-dn-00:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp mapred-site.xml tmpl-dn-01:/home/hadoop/hadoop-3.4.0/etc/hadoop
```

Теперь можно запустить `yarn`:
```bash
ssh tmpl-nn
hadoop-3.4.0/sbin/start-yarn.sh
```
 Также запустим `historyserver`:
```bash
mapred --daemon start historyserver
```

Вернемся на `jn` и настроим `nginx`, чтобы увидеть web интерфейс. 
Создадим файлы `/etc/nginx/sites-available/ya` и `/etc/nginx/sites-available/dh` на основе `/etc/nginx/sites-available/nn`, но со своими портами:
```bash
ssh tmpl-nn
sudo cp /etc/nginx/sites-available/nn /etc/nginx/sites-available/ya
sudo cp /etc/nginx/sites-available/nn /etc/nginx/sites-available/dh
```

### `/etc/nginx/sites-available/ya`

```nginx
server {
 listen 8088;


 root /var/www/html;

 # Add index.php to the list if you are using PHP
 index index.html index.htm index.nginx-debian.html;

 server_name _;

 location / {
  proxy_pass http://tmpl-nn:8088;
 }
}
```

### `/etc/nginx/sites-available/dh`

```nginx
server {
 listen 19888;


 root /var/www/html;

 # Add index.php to the list if you are using PHP
 index index.html index.htm index.nginx-debian.html;

 server_name _;

 location / {
  proxy_pass http://tmpl-nn:19888;
 }
}
```

Сделаем конфигурации активными:

```bash
sudo ln -s /etc/nginx/sites-available/ya /etc/nginx/sites-enabled/ya
sudo ln -s /etc/nginx/sites-available/dh /etc/nginx/sites-enabled/dh
sudo systemctl reload nginx
```

Для проброски портов через локальный терминал выполним команду:
```bash
ssh -L 9870:127.0.0.1:9870 -L 8088:127.0.0.1:8088 -L 19888:127.0.0.1:19888 team@176.109.91.5
```

