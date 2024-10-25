## Usage

```sh
docker-compose up -d
```
or
```sh
docker run --name redis \
-p 6379:6379 \
-v ./redis/redis.conf:/etc/redis/redis.conf \
-v ./data:/data \
-d registry.cn-guangzhou.aliyuncs.com/kubernetes-default/redis:6.0.20 redis-server /etc/redis/redis.conf
```

### Sample Configuration File

```bash
wget https://raw.githubusercontent.com/redis/redis/6.0/redis.conf
```

## Tips

- 连接测试 redis

```
docker run --rm --name redis-cli -it goodsmileduck/redis-cli redis-cli -h hostname -p 6379 ping
```