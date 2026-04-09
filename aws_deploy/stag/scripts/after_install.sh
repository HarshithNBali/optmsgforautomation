#!/bin/bash

# Update ownership of the optmsg directory
sudo chown -R ubuntu:ubuntu /home/ubuntu/web

# Install node dependencies
cd /home/ubuntu/web

# Update the codebase from web to document root
sudo rsync -av --delete --exclude='.htaccess'  /home/ubuntu/web/ /var/www/html/web/