#!/bin/bash

# Monitoring Setup Script for Solapur Turf Booking App

echo "Setting up monitoring and logging..."

# Create log directories
mkdir -p logs
mkdir -p /var/log/turf-app

# Setup PM2 log rotation
pm2 install pm2-logrotate
pm2 set pm2-logrotate:max_size 10M
pm2 set pm2-logrotate:retain 7
pm2 set pm2-logrotate:compress true

# Setup log rotation for application logs
cat > /etc/logrotate.d/turf-app << 'EOF'
/var/www/solapur-turf-app/backend/logs/*.log {
    daily
    rotate 14
    compress
    delaycompress
    missingok
    notifempty
    create 0640 www-data www-data
    sharedscripts
}
EOF

# Install monitoring tools
npm install -g pm2-server-monit

echo "Monitoring setup complete!"
echo "View logs: pm2 logs"
echo "View metrics: pm2 monit"

