#!/bin/bash
# SSL setup script for Codebase Genius
# Usage: ./ssl-setup.sh yourdomain.com

set -e

DOMAIN=$1
EMAIL="admin@$DOMAIN"

if [ -z "$DOMAIN" ]; then
    echo "Usage: $0 yourdomain.com"
    exit 1
fi

echo "Setting up SSL for $DOMAIN..."

# Install Certbot
sudo apt update
sudo apt install -y certbot python3-certbot-nginx

# Stop Nginx temporarily
sudo systemctl stop nginx

# Get SSL certificate
sudo certbot certonly --standalone -d $DOMAIN --email $EMAIL --agree-tos --non-interactive

# Copy certificates to deployment directory
sudo cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem deployment/nginx/ssl/cert.pem
sudo cp /etc/letsencrypt/live/$DOMAIN/privkey.pem deployment/nginx/ssl/key.pem
sudo cp /etc/letsencrypt/live/$DOMAIN/chain.pem deployment/nginx/ssl/chain.pem

# Generate DH parameters
sudo openssl dhparam -out deployment/nginx/ssl/dhparam.pem 2048

# Set proper permissions
sudo chown -R $USER:$USER deployment/nginx/ssl/
sudo chmod 600 deployment/nginx/ssl/*.pem

# Enable auto-renewal
sudo crontab -l | { cat; echo "0 12 * * * /usr/bin/certbot renew --quiet"; } | sudo crontab -

echo "SSL setup completed for $DOMAIN"
