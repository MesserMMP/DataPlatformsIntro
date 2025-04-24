#!/bin/bash

# Активация виртуального окружения и установка Prefect
python3 -m venv venv
source venv/bin/activate
pip install prefect


# Запуск Prefect-потока
python3 etl_flow.py
