# docker-compose-for-redis-sentinel
使用docker-compose搭建一个 redis-sentinel 环境

conf 目录是每个容器的配置文件
docker-compose   up -d
#下线
#docker-compose   up -d

docker run -it --name redis- -v /root/redis.conf:/usr/local/etc/redis/redis.conf -d -p 6379:6379 redis:latest /bin/bash