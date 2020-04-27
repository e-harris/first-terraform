#!/bin/bash


# echo "${my_name}"
cd /home/ubuntu/app
npm install
pm2 start app.js
