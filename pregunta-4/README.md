## Implementación

Toda la infraestructura fue generada y desarrollada utilizando **Inteligencia Artificial (Claude)**, desde la arquitectura hasta cada archivo de Terraform. El único paso manual fue la configuración del registro CNAME en Cloudflare.

Se utilizó **Terraform** para crear toda la infraestructura en AWS como código (IaC). El ambiente consiste en un fleet elástico de 2 servidores web detrás de un Application Load Balancer, con acceso público únicamente a través de **Cloudflare** como proxy.

### Resultado

El sitio puede ser visitado en:

> [pregunta4.prosaludsocial.site](https://pregunta4.prosaludsocial.site)

Inicializar y aplicar la infraestructura:

```bash
terraform init
terraform plan
terraform apply
```

## Verificación

Outputs al finalizar el `terraform apply`:

```
alb_dns_name  = "http://elastic-web-alb-544041908.us-east-1.elb.amazonaws.com"
ami_used      = "ami-0cb4805a67d37bd33"
asg_name      = "elastic-web-asg"
vpc_id        = "vpc-xxxxxxxxxxxxxxxxx"
```

Confirmar las instancias del Auto Scaling Group desde la CLI:

```bash
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names elastic-web-asg \
  --query 'AutoScalingGroups[0].Instances[*].{ID:InstanceId,State:LifecycleState,Health:HealthStatus}' \
  --output table
```

```
----------------------------------------------
|     DescribeAutoScalingGroups              |
+----------------------+---------+-----------+
|          ID          | Health  |   State   |
+----------------------+---------+-----------+
|  i-0a1b2c3d4e5f6a7b8 | Healthy | InService |
|  i-0b2c3d4e5f6a7b8c9 | Healthy | InService |
+----------------------+---------+-----------+
```

## Cloudflare

> ⚠️ aso configurado manualmente.

El tráfico al ALB está restringido únicamente a las IPs de Cloudflare. El dominio `pregunta4.prosaludsocial.site` apunta al ALB mediante un registro CNAME con proxy activado ☁️.

```
Tipo:    CNAME
Nombre:  pregunta4
Target:  elastic-web-alb-544041908.us-east-1.elb.amazonaws.com
Proxy:   ☁️ ON
SSL:     Flexible
```