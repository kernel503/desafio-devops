# Kubernetes Cluster Setup con Terraform y Kubeadm

## Descripción

Despliegue de un clúster de Kubernetes en máquinas virtuales aprovisionadas con Terraform, utilizando `kubeadm` para la configuración del clúster, Calico como CNI y Metrics Server para la recolección de métricas.

---

## Infraestructura

Se ejecutó el plan de Terraform para provisionar la infraestructura base, creando **2 máquinas virtuales**:

| Rol    | Hostname  |
|--------|-----------|
| Master | `kmaster` |
| Worker | `worker1` |

---

## 1. Inicialización del nodo Master

Conectarse vía SSH al nodo master y ejecutar el siguiente comando para inicializar el clúster:

```bash
sudo kubeadm init --pod-network-cidr=192.168.0.0/16
```

> El flag `--pod-network-cidr=192.168.0.0/16` es requerido por Calico para la configuración de red de pods.

Una vez finalizado, `kubeadm` generará el comando de join necesario para unir los nodos worker. Guardarlo para el siguiente paso.

Configurar `kubectl` para el usuario actual:

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

---

## 2. Unión del nodo Worker al clúster

Conectarse vía SSH al nodo worker y ejecutar el comando de join generado en el paso anterior. Ejemplo:

```bash
sudo kubeadm join kmaster:6443 --token 00qkvy.5544ompgbghf95ne \
    --discovery-token-ca-cert-hash sha256:8f3acd5eb93096327e92ca5d4593b094f755b549e7e6bb65cb9f3861f045243b
```

> El token y el hash son únicos por cada inicialización, el comando anterior es solo de referencia. Usar siempre los valores generados por `kubeadm init`.

---

## 3. Instalación de Calico (CNI)

Calico actúa como plugin de red (CNI) encargado de gestionar la comunicación entre pods dentro del clúster. Se instala desde el nodo master aplicando los siguientes manifiestos:

```bash
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.32.1/manifests/v1_crd_projectcalico_org.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.32.1/manifests/tigera-operator.yaml
```

---

## 4. Instalación de Metrics Server

Metrics Server recolecta métricas de uso de CPU y memoria de los nodos y pods, necesarias para comandos como `kubectl top`. Desde el nodo master, aplicar el manifiesto oficial:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

### Modificación del Deployment

Dado que el entorno no dispone de certificados TLS válidos entre componentes, se editó el deployment para agregar el flag `--kubelet-insecure-tls` en los argumentos del contenedor, permitiendo que Metrics Server se comunique con el kubelet sin validar el certificado:

```bash
kubectl edit deployment metrics-server -n kube-system
```

Agregar en la sección `args`:

```yaml
- --kubelet-insecure-tls
```

Verificar que el deployment esté disponible:

```bash
kubectl get deployments.apps -n kube-system metrics-server
```

```
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
metrics-server   1/1     1            1           13h
```

---

## 5. Instalación de Helm

Helm es el gestor de paquetes para Kubernetes. Se instaló usando el script oficial:

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
chmod 700 get_helm.sh
./get_helm.sh
```

Se agregaron los siguientes repositorios para uso futuro:

```bash
helm repo add nginx-stable https://helm.nginx.com/stable
helm repo update
```

---

## 6. Instalación de NGINX Gateway Fabric

NGINX Gateway Fabric actúa como controlador de gateway para gestionar el tráfico entrante al clúster, siguiendo la especificación de Kubernetes Gateway API. Se instaló mediante Helm desde el registro OCI oficial en el namespace `nginx-gateway`:

```bash
helm install ngf oci://ghcr.io/nginx/charts/nginx-gateway-fabric --create-namespace -n nginx-gateway
```

Verificar el release instalado:

```bash
helm list -A
```

```
NAME    NAMESPACE       REVISION    STATUS      CHART                        APP VERSION
ngf     nginx-gateway   1           deployed    nginx-gateway-fabric-2.6.7   2.6.7
```

---

## 7. Despliegue de Cloudflared

Cloudflared establece un túnel seguro entre el clúster y Cloudflare, permitiendo exponer servicios internos a internet sin necesidad de abrir puertos ni configurar reglas de firewall. Se desplegó utilizando manifiestos YAML gestionados con Kustomize.

Estructura de archivos:

```
cloudflare/
├── deployment.yaml
├── kustomization.yaml
├── namespace.yaml
└── secret.yaml
```

> El archivo `secret.yaml` contiene un token inválido

Aplicar los manifiestos:

```bash
kubectl apply -k cloudflare/
```

---

## Resultado

Clúster de Kubernetes funcional con los siguientes componentes desplegados:

| Componente            | Detalle                          |
|-----------------------|----------------------------------|
| Nodo Master           | `kmaster`                        |
| Nodo Worker           | `worker1`                        |
| CNI                   | Calico v3.32.1                   |
| Metrics Server        | Operativo                        |
| Ingress / Gateway     | NGINX Gateway Fabric v2.6.7      |
| Túnel de red          | Cloudflared                      |

```bash
kubectl get nodes
```

```
NAME            STATUS   ROLES           AGE   VERSION
ip-10-0-1-229   Ready    worker          18h   v1.36.3
ip-10-0-1-67    Ready    control-plane   18h   v1.36.3
```

---

```bash
kubectl top node
```

```
NAME            CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)   
ip-10-0-1-229   75m          3%       1644Mi          44%         
ip-10-0-1-67    156m         7%       2074Mi          55%    
```