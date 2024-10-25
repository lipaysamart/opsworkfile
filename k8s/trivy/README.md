## Helm Install

```sh
helm repo add aqua https://aquasecurity.github.io/helm-charts/
helm repo update
helm install trivy-operator aqua/trivy-operator -f values.yaml  --version 0.22.1 --namespace trivy-system
```

### Resource

```bash
# 获取默认空间的漏洞报告
kubectl get vulnerabilityreports -o wide -n default

# 输出结果
NAME                                                         REPOSITORY             TAG               SCANNER   AGE   CRITICAL   HIGH   MEDIUM   LOW   UNKNOWN
replicaset-6fbf6d95f9                                        gitlab/gitlab-runner   alpine-v13.12.0   Trivy     53m   12         104    89       13    0
replicaset-gitlab-runner-gitlab-runner-c6f8cc5bb-configure   gitlab/gitlab-runner   alpine-v13.12.0   Trivy     53m   12         104    89       13    0

# 查看一个漏洞报告
kubectl get vulnerabilityreport replicaset-gitlab-runner-gitlab-runner-c6f8cc5bb-configure -o json
```

```bash
# 获取默认空间的配置审计报告
kubectl get configauditreports -o wide -n default

# 输出结果
NAME                                               SCANNER   AGE   CRITICAL   HIGH   MEDIUM   LOW
ingress-gitlab-ingress                             Trivy     67m   0          0      0        2
replicaset-gitlab-deployment-787777c966            Trivy     66m   0          3      8        8
replicaset-gitlab-runner-gitlab-runner-c6f8cc5bb   Trivy     66m   0          2      12       20

# 获取默认空间的配置审计报告
kubectl describe configauditreport replicaset-gitlab-runner-gitlab-runner-c6f8cc5bb -n default
```

## Tips

- 资源对象可以简写成 `vuln`, `configaudit`

## Reference

- [Trivy Operator](https://aquasecurity.github.io/trivy-operator/latest/getting-started/installation/helm/)