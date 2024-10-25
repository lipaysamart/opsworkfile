{{ $var := .externalURL}}{{ range $k,$v:=.alerts -}}
{{ if eq $v.status "resolved" -}}
## ✅ - [Kubernetes Recovery Notification]({{$v.generatorURL}}) 🤖

📢 | AlertName: **{{$v.labels.alertname}}**
🎯 | Level: {{ if $v.labels.severity }}
{{- if eq $v.labels.severity "info" }}<font color="comment">**info**</font>
{{- else if eq $v.labels.severity "warning" }}<font color="#67C23A">**warning**</font>
{{- else if eq $v.labels.severity "critical" }}<font color="#67C23A">**critical**</font>
{{- else if eq $v.labels.severity "emergency" }}<font color="#67C23A">**emergency**</font>
{{- else }}{{ $v.labels.severity }}
{{ end -}}
{{ end }}
💬 | Status: <font color="#67C23A">已恢复</font>
⏰ | EndTime: {{GetCSTtime $v.endsAt}}
🌎 | Cluster: {{$v.labels.cluster}}

<font color="#02b340">**{{$v.annotations.description}}**</font>

## 👨🏻‍💻 - [查看当前状态]({{$v.generatorURL}})
{{ else -}}

## 🔥 - [Kubernetes Alert Notification]({{$v.generatorURL}}) 🤖

📢 | AlertName: **{{$v.labels.alertname}}**
🎯 | Level: {{ if $v.labels.severity }}
{{- if eq $v.labels.severity "info"}}<font color="comment">**info**</font>
{{- else if eq $v.labels.severity "warning"}}<font color="#E6A23C">**warning**</font>
{{- else if eq $v.labels.severity "critical"}}<font color="#FF0000">**critical**</font>
{{- else if eq $v.labels.severity "emergency"}}<font color="#FF0000">**emergency**</font>
{{- else }}{{ $v.labels.severity }}
{{ end -}}
{{ end }}
💬 | Status: {{ if $v.labels.severity }}
{{- if eq $v.labels.severity "info"}}<font color="comment">需要检查</font>
{{- else if eq $v.labels.severity "warning"}}<font color="#E6A23C">需要处理</font>
{{- else if eq $v.labels.severity "critical"}}<font color="#FF0000">立即处理</font>
{{- else if eq $v.labels.severity "emergency"}}<font color="#FF0000">紧急处理</font>
{{- else }}{{ $v.labels.severity }}
{{ end -}}
{{ end }}
⏰ | StartsAt: {{GetCSTtime $v.startsAt}}
🌎 | Cluster: {{$v.labels.cluster}}

<font color="#E6A23C">**{{$v.annotations.description}}**</font>

## 👨🏻‍💻 - [登录告警平台]({{$var}}) 
{{ end -}}
{{ end }}