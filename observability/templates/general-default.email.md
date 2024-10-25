{{ $var := .externalURL}}{{ range $k,$v:=.alerts -}}
{{ if eq $v.status "resolved" -}}
<html>
<head>
    <title>Kubernetes Recovery Notification</title>
</head>
<body>
    <h2> 📢 | AlertName: {{ $v.labels.alertname }} </h2>
    <h2> 🛠️ | LabelDesc </h2>
    <table>
        <tr>
            <th> LabelName </th>
            <th> LabelValue</th>
        </tr>
        {{ range $key, $value:=$v.labels }}
        <tr>
            <td> {{$key}} </td>
            <td> {{$value}} </td>
        </tr>
        {{ end }}
    </table>
    <p color="#02b340"> {{$v.annotations.description}} </p>
</body>
</html>

{{- else -}}
<html>
<head>
    <title>Kubernetes Alert Notification</title>
</head>
<body>
    <h2> 📢 | AlertName: {{ $v.labels.alertname }} </h2>
    <h2> 🛠️ | LabelDesc </h2>
    <table>
        <tr>
            <th> LabelName </th>
            <th> LabelValue</th>
        </tr>
        {{ range $key, $value:=$v.labels }}
        <tr>
            <td> {{$key}} </td>
            <td> {{$value}} </td>
        </tr>
        {{ end }}
    </table>
    <p color="#E6A23C"> {{$v.annotations.description}} </p>
</body>
</html>
{{ end -}}
{{ end }}