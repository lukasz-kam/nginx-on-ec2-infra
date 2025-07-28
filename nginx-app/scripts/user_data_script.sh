#!/bin/bash

TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-ipv4)

sudo yum update -y
sudo yum install nginx -y
aws s3 cp "s3://${S3_BUCKET_NAME}/public/${S3_IMAGE_KEY}" "/usr/share/nginx/html/${S3_IMAGE_KEY}"

sudo bash -c "cat << 'EOF_HTML' > /usr/share/nginx/html/index.html
  <!DOCTYPE html>
  <html>
  <head>
      <title>NGINX</title>
      <style>
          body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }
          img { max-width: 80%; height: auto; border: 2px solid #ddd; padding: 5px; }
          .ip-address { font-size: 2em; color: #007bff; }
      </style>
  </head>
  <body>
      <h1>Nginx on EC2</h1>
      <p>Instance private IP address is:</p>
      <p class="ip-address">$${INSTANCE_IP}</p>
      <p>Image downloaded from S3:</p>
      <img src=${S3_IMAGE_KEY} >
  </body>
  </html>
EOF_HTML"

sudo systemctl start nginx
sudo systemctl enable nginx