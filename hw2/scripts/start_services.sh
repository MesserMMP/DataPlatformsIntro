#!/bin/bash

set -e

echo "🚀 Запуск YARN"
~/hadoop-3.4.0/sbin/start-yarn.sh

echo "📜 Запуск HistoryServer"
mapred --daemon start historyserver
