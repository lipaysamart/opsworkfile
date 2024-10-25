# SRE-Observability

>记录自己搭建整套可观测性的过程。

## Introduction

>日志系统方案使用 `FLAG` 结构，由 `Fluent-bit` 数据采集 + `Loki` 做数据读/写/存 + `Alertmanager` 告警 + `Grafana` 展示组成。 

- `Loki` 日志记录引擎，负责存储日志和处理查询，查询时基于标签特性
- `Promtail` 代理，负责收集日志并将其发送给 `loki`，是专门为 `Loki` 量身定制的日志采集器，支持多种格式并进行结构化日志
- `Grafana` **UI** 界面，用于可视化和监控数据的工具，与 `Kibana` 相似。它提供了丰富的图表和仪表盘，可以帮助用户实时监控和分析日志数据。


>指标系统方案使用 `2VAG` 结构，由 `VMAgent` 数据采集 + `VictoriaMetrics` 统一存储 + `Alertmanager` 告警 + `Grafana` 展示组成。

- `Victoria-Metrics` **(VM)** 是一个高性能、可扩展的时序数据库和长期存储解决方案。
- 它专门针对 `Prometheus` 数据进行了优化，可以有效地存储和查询大规模的时间序列数据。
- `Victoria-Metrics` 支持 `Prometheus` 的查询语言 `PromQL`，并提供了额外的功能，数据压缩和快速数据恢复。

### Installation

```sh
k apply -f crd.yaml

helm repo add vm https://victoriametrics.github.io/helm-charts/
helm repo update
helm upgrade --install vmoperator vm/victoria-metrics-operator --version 0.24.0 -f values.yaml -n monitor --create-namespace --dry-run
```

## Specifications

### Components Version

|      Name       | Version |
| :-------------: | :-----: |
|   vmoperator    | 0.31.0  |
| vmalertmanager  | 0.25.0  |
|     vmagent     | 1.93.15 |
|     vmalert     | 1.93.15 |
|     vmauth      | 1.93.15 |
|    vmsingle     | 1.93.15 |
|     grafana     | 10.4.5  |
|    postgres     |   16    |
| prometheusalert |  4.9.1  |
|    pushprox     |  0.2.0  |

### VM-Auth

> VictoriaMetrics 组件访问入口

|              Path               |    Explain    |
| :-----------------------------: | :-----------: |
|   `https://${HOST}/targets/`    |  AgentTarget  |
|     `https://${HOST}/vmui/`     |    Metric     |
| `https://${HOST}/alertmanager/` | Alertmanager  |
|   `https://${HOST}/vmalert/`    |   AlertRule   |
|       `https://${HOST}/`        |   Dashboard   |
|       `https://${HOST}/`        | AlertTemplate |

### VM-Rule & VM-Alert

> 告警的严重等级在 `Emergency - Info` 之间。

|   Level   |                                             Explain                                              |
| :-------: | :----------------------------------------------------------------------------------------------: |
| Emergency | **最高级别的告警，表示存在紧急情况或系统崩溃**。需要立即采取紧急措施来避免进一步的损失或停机时间 |
| Critical  |          这一级别的告警**表示存在严重的问题或错误**，可能会对系统的正常运行产生重大影响          |
|  Warning  |    这一级别的告警**表示存在一些潜在的问题或异常情况**，需要引起注意，但不会对系统造成严重影响    |
|   Info    |      这是最低级别的告警，**通常用于提供一般性的信息或状态更新**。这些告警不需要立即采取行动      |

> Inhibit

- 通过定义 `severity` 级别进行抑制
- 同级别下多个告警则以告警最大单位进行抑制比如 (container <- pod <- deployment)

### Directory Structure

- `./rules` 目录中带有 `.rules` 后缀的文件为 `record` 规则文件. 未有后缀的文件为 `alert` 规则文件.

## Tips

### Alert Debug

> amtool 工具是 alertmanager中自带的用于管理和调试 `Alertmanager`。(需要注意我的 `uri` 是使用过标志 routePrefix 定向到了这个路径 `/alertmanager` )

```sh
# 查看当前告警
amtool --alertmanager.url=http://localhost:9093/alertmanager alert
```
```sh
# 以 json 格式输出告警
amtool --alertmanager.url=http://localhost:9093/alertmanager alert PublicNetPingDown -o json
```
```sh
# 校验配置文件
amtool check-config /etc/alertmanager/config/alertmanager.yaml
```

### Relabel

> 此方法用于丢弃所有指标中标签为 "channel: Local" 的指标

```yaml
    metric_relabel_configs:
      - source_labels: ["channel"]
        target_label: __channel
        action: drop
        regex: "Local"
```

> 通过 `if` 字段来匹配特定的时序，进而执行 `relabel` 

```yaml
    metric_relabel_configs:
      - action: drop
        if: '{__meta_kubernetes_namespace!="pre-prod|prod",__meta_kubernetes_ingress_path=~"/web/chat/?|/chat/?|/website/map/?|/website/?"}'

```

### Hot Reload

> 此方法同样适用于 Alertmanager

```sh
sudo curl -X POST -u isadmin:FdSp8Fxo  http://localhost:8429/-/reload
```

### Monitoring of cluster components

> 默认情况下，Operator 为其管理的每个组件创建 `VMServiceScrape` 对象, 可以使用 `VM_DISABLESELFSERVICESCRAPECREATION` 环境变量禁用此行为

```yaml
VM_DISABLESELFSERVICESCRAPECREATION=false
```

- 覆盖抓取的默认配置

```yaml
apiVersion: operator.victoriametrics.com/v1beta1
kind: VMAgent
metadata:
  name: main
  namespace: monitor
spec:
...
  serviceScrapeSpec:
    endpoints:
    - path: /metrics
      port: http
      metricRelabelConfigs:
      - action: replace
        sourceLabels:
        - scrape_job
        regex: "staticScrape/monitor/(.*)/0"
        targetLabel: purpose
        replacement: $1
```

### Metric API

> 指标被删除时只能是整个指标系列，而不能特指某个时间或特定标签范围的数据

- 删除匹配的时序指标
```sh
wget --quiet \
  --method DELETE \
  --header 'Accept: */*' \
  --header 'User-Agent: Thunder Client (https://www.thunderclient.com)' \
  --header 'Authorization: Basic xxx \
  --output-document \
  - 'https://${HOST}/prometheus/api/v1/admin/tsdb/delete_series?match%5B%5D=probe_dns_lookup_time_seconds'
```

- 查看匹配的时序指标
```sh
wget --quiet \
  --method GET \
  --header 'Accept: */*' \
  --header 'User-Agent: Thunder Client (https://www.thunderclient.com)' \
  --header 'Authorization: Basic xxx \
  --output-document \
  - 'https://${HOST}/prometheus/api/v1/series?match%5B%5D=probe_success%7B%7D'
```

### RelabelConfigs

> 对于需要 mapping 所有节点标签的方法 (默认不开启)
```yaml
 - action: labelmap
   regex: __meta_kubernetes_node_label_(.+)
```

## TroubleShooting

- `vmalertmanager` 在被删除时会同时删除外挂的 `secret` 


- 自动发现在抓取 `Ingress` 时，`vmagent` 抛出异常 `skipping duplicate scrape target with identical labels;` 查看官方说明这是因为单个 `ingress` 中可能监听了多个端口。使用以下命令标志可以禁止显示这些错误.

```yaml
promscrape.suppressDuplicateScrapeTargetErrors: "true"
```

## Deprecated

## Reference

- [A set of modern Grafana dashboards for Kubernetes](https://github.com/dotdc/grafana-dashboards-kubernetes)
- [Relabeler Promlabs](https://relabeler.promlabs.com/)
- [Kube-Prometheus Runbooks](https://runbooks.prometheus-operator.dev/)
- [Monitoring Mixins](https://monitoring.mixins.dev/)