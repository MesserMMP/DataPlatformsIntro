# 🚀 HW4: Apache Spark + YARN + Hive + HDFS

## 📌 Цель

Развертывание Apache Spark под управлением YARN с интеграцией в кластер HDFS и Hive. Обработка и загрузка датасета Electric Vehicle Population Data в Hive с использованием Spark и партиционирования.

## 📁 Структура репозитория

```bash
.
├── scripts/
│   ├── 1_setup_env.sh              # Установка окружения
│   ├── 2_download_data.sh          # Скачивание и загрузка данных в HDFS
│   ├── 3_start_metastore.sh        # Запуск Hive Metastore
│   └── 4_run_spark_job.sh          # Запуск Spark-сессии и логики
├── screenshots/                    # Скриншоты из интерфейсов
├── instructions.md                # Подробная инструкция для ручного развертывания
└── README.md                      # Это описание
```

## 📘 Инструкция

Пошаговая инструкция для ручного развертывания доступна в файле [`instructions.md`](instructions.md).

## ⚙️ Требования

- Ubuntu 24.04
- Java 11.0.26
- Развернутый кластер HDFS
- Настроенный Hive Metastore
- Доступ через jump-хост

## 🚀 Быстрый запуск

На jump-ноде (или главном узле кластера):

```bash
cd scripts
bash 1_setup_env.sh
bash 2_download_data.sh
bash 3_start_metastore.sh
bash 4_run_spark_job.sh
```

После выполнения:
- Данные будут загружены в HDFS.
- Spark прочитает и трансформирует данные.
- Результаты сохранятся в Hive тремя способами.
