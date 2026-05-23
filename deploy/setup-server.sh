#!/bin/bash
# 阿里云 ECS 初始化脚本
# 在服务器上作为 ubuntu 用户执行：bash setup-server.sh （需要 sudo 权限）

set -e

echo "=== 安装 Nginx ==="
sudo apt update && sudo apt install -y nginx

echo "=== 创建站点目录 ==="
sudo mkdir -p /var/www/blog

echo "=== 配置 Nginx ==="
sudo cp nginx.conf /etc/nginx/sites-available/blog
sudo ln -sf /etc/nginx/sites-available/blog /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

echo "=== 测试 Nginx 配置 ==="
sudo nginx -t

echo "=== 重启 Nginx ==="
sudo systemctl reload nginx

echo "=== 完成 ==="
echo "博客目录: /var/www/blog"
echo "Nginx 配置: /etc/nginx/sites-available/blog"
