# Pregunta 5 - Observabilidad y Alerting

## Descripción

Implementación de observabilidad utilizando el stack **kube-prometheus-stack**, que incluye Grafana, Prometheus y OpenTelemetry para la visualización de métricas, trazas y logs del clúster.

---

## Acceso a Grafana

El dashboard puede ser visitado en:

> [pregunta5.prosaludsocial.site](https://pregunta5.prosaludsocial.site)

| Campo    | Valor                                      |
|----------|--------------------------------------------|
| Usuario  | `admin`                                    |
| Password | `WbLn9twJjd0eRj4T2bax4g6urtdMpGGAltgFs862`|

---

## Instalación

Se utilizó el Helm chart de **kube-prometheus-stack** de la comunidad de Prometheus, ya que incluye Grafana, Prometheus y los exporters necesarios para monitorear el clúster de Kubernetes de forma completa.

Agregar el repositorio:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```

Instalar el chart:

```bash
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace
```