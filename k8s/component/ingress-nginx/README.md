## Install

### Helm Install

```sh
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
```

#### 云上部署

```sh
helm install ingress-nginx ingress-nginx/ingress-nginx --version 4.7.1 --namespace ingress-nginx --create-namespace
```

#### 云上 Internal 网关部署

```sh
helm upgrade --install ingress-nginx-internal ingress-nginx/ingress-nginx \
--namespace ingress-nginx-internal --create-namespace \
--version 4.7.1 \
--set controller.ingressClassResource.name=nginx-internal \
--set controller.ingressClassResource.enabled=true \
--set controller.ingressClassResource.default=false \
--set controller.ingressClassResource.controllerValue="k8s.io/ingress-nginx" \
--set controller.ingressClass=nginx-internal
```

#### 本地部署

```sh
helm install ingress-nginx ingress-nginx/ingress-nginx  -f values.yaml --version 4.7.1 --namespace ingress-nginx --create-namespace
```

### Compatible Version

| Supported | Ingress-NGINX version | k8s supported version        | Alpine Version | Nginx Version | Helm Chart Version |
| :-------: | --------------------- | ---------------------------- | -------------- | ------------- | ------------------ |
|     🔄     | **v1.9.6**            | 1.29, 1.28, 1.27, 1.26, 1.25 | 3.19.0         | 1.21.6        | 4.9.1*             |
|     🔄     | **v1.9.5**            | 1.28, 1.27, 1.26, 1.25       | 3.18.4         | 1.21.6        | 4.9.0*             |
|     🔄     | **v1.9.4**            | 1.28, 1.27, 1.26, 1.25       | 3.18.4         | 1.21.6        | 4.8.3              |
|     🔄     | **v1.9.3**            | 1.28, 1.27, 1.26, 1.25       | 3.18.4         | 1.21.6        | 4.8.*              |
|     🔄     | **v1.9.1**            | 1.28, 1.27, 1.26, 1.25       | 3.18.4         | 1.21.6        | 4.8.*              |
|     🔄     | **v1.9.0**            | 1.28, 1.27, 1.26, 1.25       | 3.18.2         | 1.21.6        | 4.8.*              |
|     🔄     | **v1.8.4**            | 1.27, 1.26, 1.25, 1.24       | 3.18.2         | 1.21.6        | 4.7.*              |
|     🔄     | **v1.8.2**            | 1.27, 1.26, 1.25, 1.24       | 3.18.2         | 1.21.6        | 4.7.*              |
|     🔄     | **v1.8.1**            | 1.27, 1.26, 1.25, 1.24       | 3.18.2         | 1.21.6        | 4.7.*              |
|     🔄     | **v1.8.0**            | 1.27, 1.26, 1.25, 1.24       | 3.18.0         | 1.21.6        | 4.7.*              |
|           | **v1.7.1**            | 1.27, 1.26, 1.25, 1.24       | 3.17.2         | 1.21.6        | 4.6.*              |
|           | **v1.7.0**            | 1.26, 1.25, 1.24             | 3.17.2         | 1.21.6        | 4.6.*              |
|           | v1.6.4                | 1.26, 1.25, 1.24, 1.23       | 3.17.0         | 1.21.6        | 4.5.*              |
|           | v1.5.1                | 1.25, 1.24, 1.23             | 3.16.2         | 1.21.6        | 4.4.*              |
|           | v1.4.0                | 1.25, 1.24, 1.23, 1.22       | 3.16.2         | 1.19.10†      | 4.3.0              |
|           | v1.3.1                | 1.24, 1.23, 1.22, 1.21, 1.20 | 3.16.2         | 1.19.10†      | 4.2.5              |
|           | v1.3.0                | 1.24, 1.23, 1.22, 1.21, 1.20 | 3.16.0         | 1.19.10†      | 4.2.3              |

##  Recommend Annotation

>注解键和值只能是字符串。其他类型，例如布尔值或数值，必须用引号引起来，即 "true" 、 "false" 、 "100" 。
>>可以使用 --annotations-prefix 命令行参数更改注释前缀，但默认值为 `nginx.ingress.kubernetes.io`

- Enable Cors

```sh
# 启用跨域
nginx.ingress.kubernetes.io/enable-cors: "true"
# 默认值: GET, PUT, POST, DELETE, PATCH, OPTIONS
nginx.ingress.kubernetes.io/cors-allow-methods: "PUT, GET, POST, OPTIONS"
# 控制 CORS 接受的来源。
nginx.ingress.kubernetes.io/cors-allow-origin: "*"
```

- External Authentication

```sh
# 要使用提供身份验证的现有服务，用以将 HTTP 请求发送到的 URL。
nginx.ingress.kubernetes.io/auth-url: "URL to the authentication service"
```

- Permanent Redirect

```sh
# 此注释允许返回永久重定向（返回代码 301），而不是将数据发送到上游
nginx.ingress.kubernetes.io/permanent-redirect: "https://www.google.com"
```

- Redirect from/to www

```sh
# 此注释允许 www.domain.com 重定向到 domain.com
nginx.ingress.kubernetes.io/from-to-www-redirect: "true"
```

- Denylist

```sh
# 此注释指定阻止的客户端 IP 源范围。该值是逗号分隔的 CIDR 列表
nginx.ingress.kubernetes.io/denylist-source-range: "10.0.0.0/24,172.10.0.1"
```

- Whitelist

```sh
# 此注释指定阻止的客户端 IP 源范围。该值是逗号分隔的 CIDR 列表
nginx.ingress.kubernetes.io/whitelist-source-range: "10.0.0.0/24,172.10.0.1" 
```

- Timeouts

>所有超时值都是无单位的，以秒为单位

```sh
nginx.ingress.kubernetes.io/proxy-connect-timeout: "120"
nginx.ingress.kubernetes.io/proxy-send-timeout: "60"
nginx.ingress.kubernetes.io/proxy-read-timeout: "120"

```

- Client Body Size

>对于 NGINX，当请求中的大小超过客户端请求正文允许的最大大小时，将向客户端返回 413 错误。这个大小可以通过参数 client_max_body_size 来配置。

```sh
nginx.ingress.kubernetes.io/proxy-body-size: 8m
```

- Http Version

```sh
# 使用此注释设置 Nginx 反向代理将用于与后端通信的 proxy_http_version 。默认情况下，该值设置为“1.1”。
nginx.ingress.kubernetes.io/proxy-http-version: "1.0"
```

- Conn Header

```sh
# 使用此注释将覆盖 NGINX 设置的默认连接标头
nginx.ingress.kubernetes.io/connection-proxy-header: "keep-alive"
```

- Conn Log

```sh
# 默认情况下启用访问日志
nginx.ingress.kubernetes.io/enable-access-log: "false"
# 默认情况下不启用重写日志。在某些情况下，可能需要启用 NGINX 重写日志。请注意，重写日志会发送到通知级别的 error_log 文件。要启用此功能，请使用注释：
nginx.ingress.kubernetes.io/enable-rewrite-log: "true"
```

- Use Regex

```sh
# 此注释将指示 Ingress 上定义的路径是否使用正则表达式
nginx.ingress.kubernetes.io/use-regex: "true"
```

- Rewrite

```sh
# 重定向 / 的请求
nginx.ingress.kubernetes.io/app-root: "/"
```

- Canary

>Canary 规则按优先顺序进行评估。优先级如下： canary-by-header -> canary-by-cookie -> canary-weight
>>目前，每个 Ingress 规则最多可以应用一个 Canary Ingress。

```sh
nginx.ingress.kubernetes.io/canary: "true"
# 用于通知 Ingress 将请求路由到 Canary Ingress 中指定的服务的标头。当请求头设置为 always 时，它将被路由到金丝雀。当标头设置为 never 时，它永远不会被路由到金丝雀.
nginx.ingress.kubernetes.io/canary-by-header: "always"
# 用于通知 Ingress 将请求路由到 Canary Ingress 中指定的服务的 cookie。当 cookie 值设置为 always 时，它将被路由到金丝雀。当 cookie 设置为 never 时，它永远不会被路由到金丝雀。
nginx.ingress.kubernetes.io/canary-by-cookie: "always"
# 路由到金丝雀 Ingress 中指定的服务的基于整数 (0 - ) 的随机请求百分比。权重为 0 意味着此金丝雀规则不会向金丝雀入口中的服务发送任何请求
nginx.ingress.kubernetes.io/canary-weight: "30"
# 流量总权重。如果未指定，则默认为 100。
nginx.ingress.kubernetes.io/canary-weight-total: "100"

```


## Reference

- [Simple Example](https://github.com/kubernetes/ingress-nginx/tree/main/docs/examples)
- [Configuration](https://github.com/kubernetes/ingress-nginx/blob/main/charts/ingress-nginx/README.md)
- [Annotation](https://github.com/kubernetes/ingress-nginx/blob/main/docs/user-guide/nginx-configuration/annotations.md)