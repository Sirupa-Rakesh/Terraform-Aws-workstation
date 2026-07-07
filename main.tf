resource "aws_security_group" "workstation" {
  name        = "allow-all-workstation"
  description = "Allow all inbound and outbound traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "allow-all-workstation"
  }
}

resource "aws_instance" "rakesh_workstation" {
  ami                         = local.ami_id
  instance_type               = "t3.micro"
  associate_public_ip_address = true

  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.workstation.id]

  key_name = var.key_name

  user_data = templatefile("${path.module}/workstation.sh", {
    aws_access_key = var.aws_access_key
    aws_secret_key = var.aws_secret_key
  })

  root_block_device {
    volume_size = 50
    volume_type = "gp3"

    tags = merge(
      {
        Name = "${var.project}-${var.environment}-workstation"
      },
      local.common_tags
    )
  }

  tags = merge(
    {
      Name = "${var.project}-${var.environment}-workstation"
    },
    local.common_tags
  )
}

resource "terraform_data" "cluster_destroy" {

  depends_on = [
    aws_instance.rakesh_workstation
  ]

  input = {
    host = aws_instance.rakesh_workstation.public_ip
  }

  provisioner "remote-exec" {
    when = destroy

    inline = [
      "sudo eksctl delete cluster -f /home/ec2-user/eksctl/eks.yaml --wait"
    ]

    connection {
      type        = "ssh"
      host        = self.input.host
      user        = "ec2-user"
        private_key = file(var.private_key_path)
      timeout     = "10m"
    }
  }
}

  // Variable for path to the SSH private key used for remote-exec connections
  variable "private_key_path" {
    description = "Path to the SSH private key file for connecting to the instance"
    type        = string
    default     = "~/.ssh/id_rsa"
  }

  // Variable for the EC2 Key Pair name to attach to the instance
  variable "key_name" {
    description = "Name of the EC2 Key Pair to use for the instance"
    type        = string
  }