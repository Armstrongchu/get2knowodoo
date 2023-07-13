#!/bin/bash
container=odoo_proxy
read -p "Enter the domain name: " domain


echo 'register certificate'
docker exec -it "$container" certbot --nginx -d "$domain"

echo "server {
    listen 80;
    server_name "$domain";
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name $domain;

    ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;

    location / {
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$remote_addr;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header Host \$host;
        proxy_pass http://odoo:8069;
        add_header Content-Security-Policy upgrade-insecure-requests;
    }
}" | sudo tee -a /home/ubuntu/multitenant/config/nginx/default.conf


echo 'reload nginx'

docker exec "$container" nginx -s reload


