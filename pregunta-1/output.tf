output "vpc_id" {
  description = "ID de la VPC test-k8s"
  value       = aws_vpc.test_k8s.id
}

output "subnet_id" {
  description = "ID de la Subnet privada"
  value       = aws_subnet.test_k8s.id
}

output "instances" {
  description = "IPs de los nodos"
  value = {
    for name, instance in aws_instance.k8s_nodes : name => {
      public_ip  = instance.public_ip
      private_ip = instance.private_ip
    }
  }
}