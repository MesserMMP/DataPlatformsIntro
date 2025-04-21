# HW1: HDFS Cluster Deployment

## Описание

Этот проект содержит:
- Пошаговую инструкцию по развертыванию HDFS-кластера (3 DataNode, NameNode, Secondary NameNode)
- Автоматизирующие скрипты на bash

## Структура

- `instructions.md` — ручная инструкция
- `scripts/` — bash-скрипты автоматизации
- `README.md` — краткое описание

## Развёртывание

1. Склонируйте репозиторий
2. Отредактируйте IP-адреса и имена хостов при необходимости
3. Запустите скрипты по порядку из папки `scripts/`

Пример:
```bash
bash scripts/01-distribute-ssh-key.sh
bash scripts/02-update-hosts.sh
bash scripts/03-create-hadoop-user.sh
bash scripts/04-java-check-and-env.sh
bash scripts/05-distribute-hadoop.sh
bash scripts/06-configure-hadoop.sh
bash scripts/07-distribute-configs.sh
bash scripts/08-update-hostnames.sh
bash scripts/09-start-cluster.sh
```

## Автор

- Студент ФКН ВШЭ
