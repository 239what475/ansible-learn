{{- define "web-demo.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "web-demo.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- include "web-demo.name" . -}}
{{- end -}}
{{- end -}}

{{- define "web-demo.labels" -}}
app.kubernetes.io/name: {{ include "web-demo.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end -}}

{{- define "web-demo.selectorLabels" -}}
app.kubernetes.io/name: {{ include "web-demo.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
