#!/bin/bash
# Настройка переменных окружения Hive

echo '
export HIVE_HOME=$HOME/apache-hive-4.0.0-alpha-2-bin
export HIVE_CONF_DIR=$HIVE_HOME/conf
export HIVE_AUX_JARS_PATH=$HIVE_HOME/lib/*
export PATH=$PATH:$HIVE_HOME/bin
' >> ~/.profile

source ~/.profile
