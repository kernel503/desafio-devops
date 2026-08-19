# Tarea - Kubernetes, IaC y Observabilidad

## Descripción

Solución a los enunciados de la tarea, implementando un clúster de Kubernetes en AWS, despliegues con manifiestos y Helm, infraestructura como código con Terraform, y observabilidad con Grafana y OpenTelemetry. Todo implementado mediante pipelines en Azure DevOps.

---

## Estructura del repositorio

```
.
├── pregunta1/          # Archivos de configuración del clúster de Kubernetes
├── pregunta2/          # Manifiestos de Kubernetes para el deployment de Nginx
├── pregunta3/          # Helm chart y archivos de configuración
├── pregunta4/          # Archivos de IaC con Terraform
├── pregunta5/          # Configuración de Grafana, OpenTelemetry y dashboards
└── README.md
```

> Cada directorio sigue la estructura `preguntaN/seccion1/` y `preguntaN/seccion2/` según lo solicitado.

---

## Pipelines

Todos los despliegues fueron implementados mediante pipelines en **Azure DevOps**. Cada directorio de pregunta contiene su respectivo archivo de pipeline.

---

## Enunciados

### Pregunta 1 - Clúster de Kubernetes (30pt)

**Enunciado:** Crear un clúster de Kubernetes en la nube de AWS o Azure, utilizando KOps o Kubeadm. Este clúster se utilizará para las siguientes 2 preguntas.

**Entregable:** Mostrar el clúster arriba y funcionando, junto con los archivos de configuración.

Directorio: [`pregunta-1/`](./pregunta-1/)

---

### Pregunta 2 - Deployment con Nginx (10pt)

**Enunciado:** Crear un deployment que:

1. Utilice Nginx como imagen
2. Que la index page muestre "Hola Mundo {tu nombre}"
3. Se levanten 2 réplicas
4. Estrategia de implementación: RollingUpdate
5. Mínimo requerido de CPU 10m y mínimo de memoria requerida 64Mi
6. Crear un HorizontalPodAutoscaler:
   - Mínimo de réplicas 2 y máximo 10
   - Debe crecer con base a la memoria, luego de sobrepasar el 10% utilizado

**Entregable:** Todos los YAML utilizados para aplicar los cambios en Kubernetes.

Directorio: [`pregunta-2/`](./pregunta-2/)

---

### Pregunta 3 - Helm Chart (10pt)

**Enunciado:** Utilizando un Helm chart predefinido con licencia opensource, levantar un servidor web que:

1. Que la index page muestre "Hola Mundo me gusta jugar con kubernetes"
2. Que tenga 2 réplicas
3. Mínimo requerido de CPU 10m y mínimo de memoria requerida 64Mi

**Entregable:** Helm chart y los propios cambios en el ambiente.

Directorio: [`pregunta-3/`](./pregunta-3/)

---

### Pregunta 4 - Fleet con IaC (25pt)

**Enunciado:** Crear utilizando IaC (Terraform) el siguiente ambiente:

1. Un fleet de 2 servidores que corran un servidor web, accedidos por internet únicamente a través de un balanceador de carga
2. El fleet debe ser elástico, si se borra un servidor crece otro inmediatamente
3. El sistema operativo debe incluir:
   - Un usuario de seguridad con permisos de sudo
   - Sincronización con NTP
   - Logs de auditoría
   - Todos los updates aplicados
4. El webserver debe mostrar en la index "Estos servidores son elásticos"
5. El networking de la subred debe ser creado con IaC

**Entregable:** Mostrar el fleet arriba y funcionando junto con los archivos de IaC.

Directorio: [`pregunta-4/`](./pregunta-4/)

---

### Pregunta 5 - Observabilidad y Alerting (25pt)

**Enunciado:** Implementar Observabilidad y Alerting con Grafana opensource y OpenTelemetry:

1. Crear un dashboard en Grafana donde se visualicen métricas, trazas y logs de la solución
2. Visualizar la configuración inicial de alertas operativas: tiempos de respuesta, tasas de error y salud del sistema
3. Generar mayor visibilidad en tiempo real para diagnóstico y desempeño de aplicaciones

**Entregable:** Dashboard creado, collector, configuración y YAML utilizados, trazas y logs generados.

Directorio: [`pregunta-5/`](./pregunta-5/)

---

## Puntaje

| Pregunta | Descripción                       | Puntaje  |
|----------|-----------------------------------|----------|
| 1        | Clúster de Kubernetes con kubeadm | 30pt     |
| 2        | Deployment Nginx + HPA            | 10pt     |
| 3        | Helm Chart servidor web           | 10pt     |
| 4        | Fleet elástico con Terraform      | 25pt     |
| 5        | Observabilidad con Grafana + OTel | 25pt     |
| **Total**|                                   | **100pt**|