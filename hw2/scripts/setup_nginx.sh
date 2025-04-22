#!/bin/bash

set -e

echo "⚙️ Настройка NGINX для портов 9870, 8088, 19888"

sudo tee /etc/nginx/sites-available/nn > /dev/null <<EOF
server {
 listen 9870;
 root /var/www/html;
 index index.html index.htm index.nginx-debian.html;
 server_name _;
 location / {
  proxy_pass http://tmpl-nn:9870;
 }
}
EOF

sudo tee /etc/nginx/sites-available/ya > /dev/null <<EOF
server {
 listen 8088;
 root /var/www/html;
 index index.html index.htm index.nginx-debian.html;
 server_name _;
 location / {
  proxy_pass http://tmpl-nn:8088;
 }
}
EOF

sudo tee /etc/nginx/sites-available/dh > /dev/null <<EOF
server {
 listen 19888;
 root /var/www/html;
 index index.html index.htm index.nginx-debian.html;
 server_name _;
 location / {
  proxy_pass http://tmpl-nn:19888;
 }
}
EOF

sudo ln -sf /etc/nginx/sites-available/nn /etc/nginx/sites-enabled/nn
sudo ln -sf /etc/nginx/sites-available/ya /etc/nginx/sites-enabled/ya
sudo ln -sf /etc/nginx/sites-available/dh /etc/nginx/sites-enabled/dh

sudo systemctl reload nginx
