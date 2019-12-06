# Docker image for redis sentinel
# VERSION 0.0.1
# Author: bolingcavalry

#基础镜像使用官方redis:3
FROM redis

#作者
MAINTAINER panpan
#对外暴露26379接口
EXPOSE 26379
#替换原有的sentinel.conf文件
ADD sentinel.conf /etc/redis/sentinel.conf
RUN chown redis:redis /etc/redis/sentinel.conf
#定义环境变量
ENV SENTINEL_QUORUM 2
ENV SENTINEL_DOWN_AFTER 30000
ENV SENTINEL_FAILOVER 180000
#把容器启动时要执行的脚本复制到镜像中
COPY sentinel-entrypoint.sh /usr/local/bin/
#给脚本添加可执行权限
RUN chmod +x /usr/local/bin/sentinel-entrypoint.sh
#定义启动容器时自动执行的脚本
ENTRYPOINT ["sentinel-entrypoint.sh"]