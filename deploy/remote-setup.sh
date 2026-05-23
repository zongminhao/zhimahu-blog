#!/bin/bash
# 在服务器上运行：bash remote-setup.sh

set -e

echo "=== 安装 Nginx ==="
sudo apt update && sudo apt install -y nginx

echo "=== 创建站点目录 ==="
sudo mkdir -p /var/www/blog

echo "=== 配置 Nginx ==="
sudo tee /etc/nginx/sites-available/blog > /dev/null << 'NGINXEOF'
server {
    listen 80;
    server_name 39.97.232.114;

    root /var/www/blog;
    index index.html;

    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options "SAMEORIGIN";

    error_page 404 /404.html;

    location ~* \.(css|js|jpg|jpeg|png|gif|ico|svg|woff2?)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    location / {
        try_files $uri $uri/ $uri.html =404;
    }
}
NGINXEOF

sudo ln -sf /etc/nginx/sites-available/blog /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

echo "=== 添加部署 SSH 公钥 ==="
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFTG7QZzJzbfgJmoQ4tDUywzK7s3L+yOGEFD8RGPGw3/ blog-deploy' >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

echo "=== 测试 Nginx 配置 ==="
sudo nginx -t

echo "=== 重启 Nginx ==="
sudo systemctl reload nginx

echo "=== 完成 ==="
echo "博客目录: /var/www/blog"
echo "访问地址: http://39.97.232.114"
