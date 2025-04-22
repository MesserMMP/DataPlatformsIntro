#!/bin/bash

set -e

CONFIG_DIR=~/hadoop-3.4.0/etc/hadoop

for NODE in tmpl-nn tmpl-dn-00 tmpl-dn-01; do
    echo "📁 Копирую конфиги на $NODE..."
    scp $CONFIG_DIR/yarn-site.xml $NODE:$CONFIG_DIR/
    scp $CONFIG_DIR/mapred-site.xml $NODE:$CONFIG_DIR/
done
