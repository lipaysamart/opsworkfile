## Install

### Install CRDs

> CRD 和 程序不建议都用 Helm 装, 以便到时候 Helm 卸载时, CRD 不会被删除。

```sh
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.yaml
```

### Helm Install

```sh
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install \
  cert-manager jetstack/cert-manager \
  --set prometheus.enabled=false \ 
  --set webhook.timeoutSeconds=10 \
  --namespace cert-manager \
  --create-namespace \
  --version v1.11.0 \
  --dry-run
```

### Check Certificat

1. DNS-01 校验
DNS-01 的校验原理是利用 DNS 提供商的 API Key 拿到 DNS 控制权限， 在 Let’s Encrypt 为 ACME 客户端提供令牌后，ACME 客户端 (cert-manager) 将创建从该令牌和我的帐户密钥派生的 TXT 记录，并将该记录放在 _acme-challenge。 然后 Let’s Encrypt 将向 DNS 系统查询该记录，如果找到匹配项，就可以颁发证书。此方法支持泛域名证书。

2. HTTP-01 校验
HTTP-01 的校验原理是给域名指向的 HTTP 服务增加一个临时 location ，Let’s Encrypt 会发送 HTTP 请求到 http:///.well-known/acme-challenge/，参数中 YOUR_DOMAIN 就是被校验的域名，TOKEN 是 ACME 协议的客户端负责放置的文件，ACME 客户端就是 cert-manager，它通过修改或创建 Ingress 规则来增加这个临时校验路径并指向提供 TOKEN 的服务。Let’s Encrypt 会对比 TOKEN 是否符合预期，校验成功后就会颁发证书。此方法仅适用于给使用 Ingress 暴露流量的服务颁发证书，不支持泛域名证书。

### Simple Example

1. 创建CA集群证书颁发者:

```sh
# ClusterIssuer.yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt
spec:
  acme:
    email: example@gmail.com
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: issuer-account-key
    solvers:
    - http01:
        ingress:
          class: nginx
```

1. HTTP-01 配置示例:
这个配置示例仅供参考，使用这种方式，有多少的 Ingress 服务，就需要申请多少张证书，比较麻烦，但是配置较为简单，不依赖 DNS 服务商。

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt
  name: example-ingress
spec:
  ingressClassName: nginx
  rules:
  - host: example.k8s.local
    http:
      paths:
      - backend:
          service:
            name: example-service
            port:
              number: 80
        path: /
        pathType: Prefix
  tls:
  - hosts:
    - example.k8s.local
    secretName: example-tls
```

## Reference

- [TroubleShooting](https://cert-manager.io/docs/troubleshooting/acme/)
- [cert-manager 续订证书失败](https://github.com/cert-manager/cert-manager/issues/3896)
- [颁发 HTTP-01 证书时，Challenge 为 404 期待 200](https://github.com/cert-manager/cert-manager/issues/2517)
- [cert-manager 升级更新](https://cert-manager.io/docs/installation/upgrade/)
- [cert-manager 所有 CRD 资源对象备份](https://cert-manager.io/docs/devops-tips/backup/)