variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-2"
}

variable "ami_id" {
  description = "AMI ID para las instancias"
  type        = string
  default     = "ami-0e5497a77ef21b5ac"
}

variable "instance_type" {
  description = "Tipo de instancia"
  type        = string
  default     = "c7i-flex.large"
}

variable "volume_size" {
  description = "Tamaño del disco en GB"
  type        = number
  default     = 20
}

variable "public_key" {
  description = "Ruta a la llave publica SSH"
  type        = string
  default     = "credencial/test-k8s.pub"
}