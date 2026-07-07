variable "project" {
    default = "roboshop"
}

variable "environment" {
    default = "dev"
}

variable "aws_access_key" {
    description = "AWS Access Key ID for configuring the workstation"
    type        = string
    sensitive   = true
}

variable "aws_secret_key" {
    description = "AWS Secret Access Key for configuring the workstation"
    type        = string
    sensitive   = true
}

variable "ssh_password" {
    description = "SSH password for ec2-user to run destroy-time provisioner"
    type        = string
    sensitive   = true
}