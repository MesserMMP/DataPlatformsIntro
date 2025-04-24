#!/bin/bash
sudo -i -u hadoop bash <<EOF
nohup hive --hiveconf hive.server2.enable.doAs=false \
     --hiveconf hive.security.authorization.enabled=false \
     --service metastore > /tmp/metastore.log 2>&1 &
EOF

echo "✅ Hive Metastore запущен"
