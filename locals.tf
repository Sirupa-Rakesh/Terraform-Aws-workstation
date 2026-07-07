locals {
    ami_id =  data.aws_ami.rakesh_workstation.id
    common_tags = {
        Project = var.project
        Environment = var.environment
        Terraform = "true"
    }
}