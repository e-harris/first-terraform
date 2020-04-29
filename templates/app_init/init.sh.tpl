#!/bin/bash


echo "export DB_HOST='mongodb://${mongodb_private_IP}:27017/posts'" >> ~/.bashrc

export DB_HOST='mongodb://${mongodb_private_IP}:27017/posts'
source /home/ubuntu/.bashrc



cd /home/ubuntu/app
"sudo chown -R 1000:1000 '/home/ubuntu/.npm'"
npm install
node seeds/seed.js
pm2 start app.js
