#!/usr/bin/env bash

#无密码
docker run -itd --name redis-test -p 6379:6379 redis

#docker exec -it redis redis-cli
#docker run -v $PWD/redis.conf:/usr/local/etc/redis/redis.conf --name redis redis redis-server /usr/local/etc/redis/redis.conf