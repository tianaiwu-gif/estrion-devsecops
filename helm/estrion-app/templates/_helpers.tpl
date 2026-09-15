{{- define "estrion-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "estrion-app.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- include "estrion-app.name" . }}
{{- end }}
{{- end }}

{{- define "estrion-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "estrion-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
