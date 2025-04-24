# 🚀 HW4: Apache Spark + YARN + Hive + HDFS

## 📌 Цель

Развертывание Apache Spark под управлением YARN с интеграцией в кластер HDFS и Hive. Обработка и загрузка датасета Electric Vehicle Population Data в Hive с использованием Spark и партиционирования.

## 📁 Структура репозитория

```bash
.
├── scripts/
│   ├── 1_setup_env.sh
│   ├── 2_download_data.sh
│   ├── 3_start_metastore.sh
│   └── 4_run_spark_job.sh
├── README.md
```

## ⚙️ Требования

- Ubuntu 24.04
- Python 3.12.3
- Java 11.0.26
- Развернутый кластер HDFS
- Настроенный Hive Metastore
- Доступ через jump-хост

## 🚀 Быстрый запуск

```bash
cd scripts
bash 1_setup_env.sh
bash 2_download_data.sh
bash 3_start_metastore.sh
bash 4_run_spark_job.sh
```

## 📝 Автор

[Твое Имя] — Студент ФКН ВШЭ, курс "Введение в платформы данных", 2025
