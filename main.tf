resource "aws_instance" "workstation" {
  ami                     = local.ami_id
  instance_type           = "t3.micro"
  vpc_security_group_ids  = [aws_security_group.workstation.id]

  user_data = templatefile("workstation.sh", {
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

resource "aws_security_group" "workstation" {
  name        = "allow-all-workstation"
  description = "Allow TLS inbound traffic and all outbound traffic"

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow-all-workstation"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Single, merged terraform_data resource for cluster teardown
resource "terraform_data" "cluster_destroy" {
  input = {
    host     = aws_instance.workstation.public_ip
    password = var.ssh_password
  }

  connection {
    type     = "ssh"
    user     = "ec2-user"
    host     = self.input.host
    password = self.input.password
  }

  provisioner "remote-exec" {
    when       = destroy
    on_failure = continue

    inline = [
      <<-EOT
        if eksctl get cluster --name roboshop --region us-east-1 >/dev/null 2>&1; then
          eksctl delete cluster --name roboshop --region us-east-1 --wait
        else
          echo "Cluster roboshop not found, skipping delete."
        fi
      EOT
    ]
  }
}

# Enti jarugutundi ante:-
# Terraform destroy run cheసినappudu, workstation server ki SSH tho connect avuthundi.
# ఆ tarvata remote-exec script run avuthundi. Script mundu eksctl get cluster --name roboshop ani check chestundi - roboshop cluster undha ledha ani.
# Cluster already delete ayindi kabatti, ee check command fail avuthundi. Kani script lo if condition already pettamu kada - adi fail ayithe automatic ga else loki veltundi, just "cluster not found, skipping" ani print chesi, success (exit 0) tho bayata padtundi.
# So mొత్తం (overall) script "success" ayyindi ani terraform anukuntundi. Error raadu. Instance, security group anni clean ga destroy ayipotayi.

# on_failure = continue enduku pettam ante - idi just backup safety. Script lo unna if/else already handle chesthundi kabatti idi actually avasaram ledu ee case lo, kani vేరే yedaina unexpected issue (SSH fail, eksctl command dorakakapovadam) vaste, adi kuda block avvakunda destroy continue avvadaniki pettamu.
# Ippudu meeru cheyalsindi:
# bashterraform destroy -auto-approve
# Idi run cheste chalu - error radu, clean ga complete avuthundi. Manual ga state rm cheyalsina avasaram kuda ledu.