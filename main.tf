

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {

filter{
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
}
}


//ECR repositories

resource "aws_ecr_repository" "webapp" {
  name = "clo835-webapp"
}

resource "aws_ecr_repository" "mysql" {
  name = "clo835-mysql"
}





resource "aws_security_group" "sg" {
  name   = "clo835-sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8081
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name               = var.key_name

  iam_instance_profile   = "LabInstanceProfile"

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              service docker start
              usermod -a -G docker ec2-user
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              yum install -y unzip
              unzip awscliv2.zip
              ./aws/install
              EOF

  tags = {
    Name = "clo835-ec2"
  }
}



output "ecr_webapp_uri" {
  value = aws_ecr_repository.webapp.repository_url
}

output "ecr_mysql_uri" {
  value = aws_ecr_repository.mysql.repository_url
}

output "ec2_public_ip" {
  value = aws_instance.web.public_ip
}