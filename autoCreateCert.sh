#!/bin/bash
container=odoo_proxy
domain=$1
email=$2

if [ -z "$domain" ]; then
read -rp "Enter the domain name: " domain
fi

if [ -z "$email" ]; then
read -rp "Enter the email name: " email
fi



echo 'register certificate'
sudo docker exec -it "$container" certbot --nginx --non-interactive --agree-tos --email "$email" -d "$domain"

if [ -f "/home/ubuntu/get2knowOdoo/config/certbot/live" ]; then

    sudo chmod +r /home/ubuntu/get2knowOdoo/config/certbot/live

fi


config_block=$(cat <<EOF
server {
    listen 80;
    server_name $domain;
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
}

EOF
)


if [ -f "/home/ubuntu/get2knowOdoo/config/certbot/live/$domain/fullchain.pem" ] && [ -f "/home/ubuntu/get2knowOdoo/config/certbot/live/$domain/privkey.pem" ]; then
    
    echo "SSL certificate exists. Updating Nginx configuration."
    
    echo "$config_block" | sudo tee -a /home/ubuntu/get2knowOdoo/config/nginx/default.conf

    echo 'reload nginx'

    sudo docker exec "$container" nginx -s reload

else
    echo "SSL certificate does not exist. Skipping Nginx configuration."
fi



