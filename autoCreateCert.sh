#!/bin/bash
container=odoo_proxy
domain=$1
email=$2

if [ -z "$domain" ]; then
read -p "Enter the domain name: " domain
fi

if [ -z "$email" ]; then
read -p "Enter the email name: " email
fi



echo 'register certificate'
sudo docker exec -it "$container" certbot --nginx --agree-tos --email "$email" -d "$domain"

sudo chmod +r /home/ubuntu/get2knowOdoo/config/certbot/live


config_block=$(cat <<EOF
server {
    listen 80;
    server_name "$domain";
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name $domain;

    location / {
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$remote_addr;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header Host \$host;
        proxy_pass http://odoo:8069;
        add_header Content-Security-Policy upgrade-insecure-requests;
    }
}

EOF
)


if [ -f "/etc/letsencrypt/live/$domain/fullchain.pem" ] && [ -f "/etc/letsencrypt/live/$domain/privkey.pem" ]; then
    
    echo "SSL certificate exists. Updating Nginx configuration."
    
    echo "$config_block" | sudo tee -a /home/ubuntu/get2knowOdoo/config/nginx/default.conf

    echo 'reload nginx'

    docker exec "$container" nginx -s reload

else
    echo "SSL certificate does not exist. Skipping Nginx configuration."
fi



