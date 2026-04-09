#!/bin/bash

# Loading the bash profile to ensure nvm and node are available
#source ~/.bashrc
#
## Install Node.js if not present
#if ! command -v node &> /dev/null; then
#    echo "Node.js not found. Installing Node.js..."
#    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
#    \. "$HOME/.nvm/nvm.sh"
#    nvm install 20
#    node -v
#fi
#
## Install PM2 if not present
#if ! command -v pm2 &> /dev/null; then
#    npm install -g pm2
#fi

# Clean up previous deployment
if [ -d "/home/ubuntu/web" ]; then
    sudo rm -rf /home/ubuntu/web
fi