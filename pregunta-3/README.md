## Instalación

Se utilizó el Helm chart de **Podinfo** ya que permite configurar de forma sencilla el número de réplicas, los recursos de CPU y memoria, y el contenido de la página de inicio mediante un archivo `values.yaml`.

### Resultado

El sitio puede ser visitado en:

> [pregunta3.prosaludsocial.site](https://pregunta3.prosaludsocial.site)

Agregar el repositorio:

```bash
helm repo add podinfo https://stefanprodan.github.io/podinfo
```

Instalar el chart con los valores personalizados:

```bash
helm install pregunta3 podinfo/podinfo \
  --namespace pregunta3 \
  --create-namespace \
  --values values.yaml
```

## Verificación

Confirmar que los recursos fueron creados correctamente:

```bash
kubectl get all -n pregunta3
```

```
NAME                                     READY   STATUS    RESTARTS   AGE
pod/pregunta3-podinfo-64c47f6fdb-fqph8   1/1     Running   0          139m
pod/pregunta3-podinfo-64c47f6fdb-nqncw   1/1     Running   0          139m

NAME                        TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
service/pregunta3-podinfo   ClusterIP   10.110.200.54   <none>        9898/TCP,9999/TCP   139m

NAME                                READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/pregunta3-podinfo   2/2     2            2           139m

NAME                                           DESIRED   CURRENT   READY   AGE
replicaset.apps/pregunta3-podinfo-64c47f6fdb   2         2         2       139m

```
