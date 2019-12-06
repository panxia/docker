# docker-compose-for-redis-sentinel
使用docker-compose搭建一个 redis-sentinel 环境

conf 目录是每个容器的配置文件
#启动
docker-compose up    -d --scale sentinel=3 --scale slave=2
#下线
docker-compose   up -d
#查看容器信息（ip 等)
docker inspect scale_master_1
#扩容
docker-compose scale slave=3
#验证哨兵数量
在client容器上执行命令 redis-cli -h 172.17.0.5 -p 26379 info Sentinel看看哨兵的信息：
root@07a2be2bf114:/data# redis-cli -h 172.17.0.5 -p 26379 info Sentinel
# Sentinel
sentinel_masters:1
sentinel_tilt:0
sentinel_running_scripts:0
sentinel_scripts_queue_length:0
sentinel_simulate_failure_flags:0
master0:name=mymaster,status=ok,address=172.17.0.3:6379,slaves=2,sentinels=3
可以看到哨兵数量为3；
#验证扩容结果
进入master容器写一条记录，再进入slave容器读这个记录，看看主从同步是否生效：

root@rabbitmq:/usr/local/work/blog# docker exec -it blog_master_1 /bin/bash
root@11c4bc32062d:/data# redis-cli
127.0.0.1:6379> set abc 123456
OK
127.0.0.1:6379> quit
root@11c4bc32062d:/data# exit
exit
root@rabbitmq:/usr/local/work/blog# docker exec -it blog_slave_2 /bin/bash
root@abcc206ff31f:/data# redis-cli
127.0.0.1:6379> get abc
"123456"
127.0.0.1:6379>



#验证高可用
执行命令 docker stop blog_master_1将master停掉
执行命令 docker logs -f blog_sentinel_1看见哨兵容器的日志如下：
1:X 10 Jan 04:37:43.358 # +sdown master mymaster 172.17.0.2 6379
1:X 10 Jan 04:37:43.458 # +new-epoch 1
1:X 10 Jan 04:37:43.458 # +vote-for-leader dae600f31e27dc2b5eef79cdb6154f4365676a04 1
1:X 10 Jan 04:37:43.865 # +config-update-from sentinel dae600f31e27dc2b5eef79cdb6154f4365676a04 172.17.0.9 26379 @ mymaster 172.17.0.2 6379
1:X 10 Jan 04:37:43.865 # +switch-master mymaster 172.17.0.2 6379 172.17.0.4 6379
1:X 10 Jan 04:37:43.865 * +slave slave 172.17.0.7:6379 172.17.0.7 6379 @ mymaster 172.17.0.4 6379
1:X 10 Jan 04:37:43.866 * +slave slave 172.17.0.2:6379 172.17.0.2 6379 @ mymaster 172.17.0.4 6379
1:X 10 Jan 04:37:48.903 # +sdown slave 172.17.0.2:6379 172.17.0.2 6379 @ mymaster 172.17.0.4 6379
可以看见发生了切换，redis集群的master由之前的 172.17.0.2 6379变成了172.17.0.4 6379；

进入blog_client_1容器，执行命令 redis-cli -h 172.17.0.4 -p 6379 info Replication 看看最新的master信息如下：
root@c451d8ecb672:/data# redis-cli -h 172.17.0.4 -p 6379 info Replication 
# Replication
role:master
connected_slaves:1
slave0:ip=172.17.0.7,port=6379,state=online,offset=22318,lag=0
master_repl_offset:22453
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:2
repl_backlog_histlen:22452
进入blog_client_1容器，执行命令 redis-cli -h 172.17.0.7 -p 6379 info Replication 看看最另一个slave信息如下，role依然是slave：
root@c451d8ecb672:/data# redis-cli -h 172.17.0.7 -p 6379 info Replication 
# Replication
role:slave
master_host:172.17.0.4
master_port:6379
master_link_status:up
master_last_io_seconds_ago:1
master_sync_in_progress:0
slave_repl_offset:28570
slave_priority:100
slave_read_only:1
connected_slaves:0
master_repl_offset:0
repl_backlog_active:0
repl_backlog_size:1048576
repl_backlog_first_byte_offset:0
repl_backlog_histlen:0
以上就是在Docker下搭建redis主从和哨兵的整个实战过程，接下来的实战，我们会用springboot访问redis高可用环境，本章的环境在下一个章的实战中会继续用到；