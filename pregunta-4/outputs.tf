output "alb_dns_name" {
  value = "http://${aws_lb.web.dns_name}"
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "asg_name" {
  value = aws_autoscaling_group.web.name
}

output "nat_public_ip" {
  value = aws_eip.nat.public_ip
}

output "ami_used" {
  value = data.aws_ami.amazon_linux_2023.id
}