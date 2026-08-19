# Nginx Deployment - pregunta2

## Descripción

Despliegue de un servidor Nginx con contenido personalizado en el namespace `pregunta2`. Incluye escalado automático mediante HPA y configuración del contenido HTML a través de un ConfigMap.

### Resultado

El sitio puede ser visitado en:

> [pregunta2.prosaludsocial.site](https://pregunta2.prosaludsocial.site)
---

## Estructura del proyecto

```
pregunta2/
├── kustomization.yaml
├── namespace.yaml
├── configmap.yaml
├── deployment.yaml
├── hpa.yaml
└── service.yaml
```

| Archivo             | Descripción                                                       |
|---------------------|-------------------------------------------------------------------|
| `kustomization.yaml`| Archivo principal de Kustomize, agrupa todos los recursos         |
| `namespace.yaml`    | Define el namespace `pregunta2`                                   |
| `configmap.yaml`    | Contiene el HTML personalizado servido por Nginx                  |
| `deployment.yaml`   | Deployment de Nginx con 2 réplicas y estrategia RollingUpdate     |
| `hpa.yaml`          | HorizontalPodAutoscaler, escala entre 2 y 10 réplicas por memoria |
| `service.yaml`      | Expone el deployment internamente en el puerto 80                 |

---

## Despliegue

Ejectuar desde el directorio pregunta-2:

```bash
kubectl apply -k .
```

Kustomize aplicará todos los recursos en el orden correcto, asignando automáticamente el namespace `pregunta2` a cada uno.

---

## Verificación

Confirmar que los recursos fueron creados correctamente:

```bash
kubectl get all -n pregunta2
```

```
NAME                                    READY   STATUS    RESTARTS   AGE
pod/nginx-deployment-7459cc8d7d-jqbtw   1/1     Running   0          110s
pod/nginx-deployment-7459cc8d7d-tg9mp   1/1     Running   0          110s

NAME                    TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/nginx-service   ClusterIP   10.104.41.87   <none>        80/TCP    2m51s

NAME                               READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-deployment   2/2     2            2           2m51s

NAME                                          DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-deployment-7459cc8d7d   2         2         2       2m51s

NAME                                            REFERENCE                     TARGETS          MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/nginx-hpa   Deployment/nginx-deployment   memory: 5%/10%   2         10        2          2m51s
```
