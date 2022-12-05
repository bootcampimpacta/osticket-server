data "aws_vpc" "bootcamp_vpc" {
  filter {
    name   = "tag:Name"
    values = ["bootcamp-vpc"]
  }
}

data "aws_subnet" "bootcamp_subnet" {
  filter {
    name   = "tag:Name"
    values = ["bootcamp-vpc"]
  }
}

module "osticket_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "osTicket-sg"
  description = "Security group para o servidor do osTicket Server"
  vpc_id      = data.aws_vpc.bootcamp_vpc.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "OsTicket Port"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_rules        = ["all-all"]
}

module "osticket_ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name                   = "OSticket-Server"
  ami                    = "ami-08c40ec9ead489470"
  instance_type          = "t2.micro"
  key_name               = "terraform"
  monitoring             = true
  vpc_security_group_ids = [module.osticket_sg.security_group_id]
  subnet_id              = data.aws_subnet.bootcamp_subnet.id
  user_data              = file("./osticket.sh")

tags = {
    Terraform = "true"
    Environment = "prod"
    Name = "osticket-Server"
    Alunos = "Fabiano e Diego"
  }
}

resource "aws_eip" "osticket-ip" {
  instance = module.osticket_ec2_instance.id
  vpc      = true
}

output "ip_acesso_osticket" {
  value = "Acesse o OsTicket pela URL http://${aws_eip.osticket-ip.public_ip}:8080/scp/"
}