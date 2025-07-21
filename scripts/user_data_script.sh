#!/bin/bash

sudo yum update -y
sudo yum install nginx -y

sudo bash -c "cat << EOF_HTML > /usr/share/nginx/html/index.html
  <!DOCTYPE html>
  <html>
  <head>
      <title>NGINX</title>
      <style>
          body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }
          img { max-width: 80%; height: auto; border: 2px solid #ddd; padding: 5px; }
      </style>
  </head>
  <body>
      <h1>Nginx on EC2</h1>
      <p>Image from S3 bucket:</p>
      <img src="${S3_IMAGE_URL}" >
  </body>
  </html>
EOF_HTML"

sudo systemctl start nginx
sudo systemctl enable nginx