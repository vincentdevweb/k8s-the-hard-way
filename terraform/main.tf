terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1" # AWS region
}

# provider "aws" {
#   region     = "us-west-2"
#   access_key = "my-access-key"
#   secret_key = "my-secret-key"
# }

# Create a VPC
resource "aws_vpc" "kubernetes_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "kubernetes-the-hard-way"
  }
}

#On link of item VPC for subnet --- SUBNET
resource "aws_subnet" "kubernetes_subnet" {
  vpc_id                  = aws_vpc.kubernetes_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a" # Change this to your desired availability zone
  map_public_ip_on_launch = true #public ip au lancement 
  tags = {
    Name = "kubernetes"
  }
}

#internet gateway link of item VPC aws_vpc (passerelle)
resource "aws_internet_gateway" "kubernetes_igw" {
  vpc_id = aws_vpc.kubernetes_vpc.id
  tags = {
    Name = "kubernetes"
  }
}

resource "aws_route_table" "kubernetes_route_table" {
  vpc_id = aws_vpc.kubernetes_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kubernetes_igw.id
  }
  tags = {
    Name = "kubernetes"
  }
}

resource "aws_security_group" "kubernetes_security_group" {
  name        = "kubernetes"
  description = "Kubernetes security group"
  vpc_id      = aws_vpc.kubernetes_vpc.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16", "10.200.0.0/16", "0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "kubernetes_lb" {
  name               = "kubernetes"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.kubernetes_subnet.id]
}

resource "aws_lb_target_group" "kubernetes_target_group" {
  name     = "kubernetes"
  port     = 6443
  protocol = "TCP"
  vpc_id   = aws_vpc.kubernetes_vpc.id
  target_type = "ip"
}

resource "aws_lb_listener" "kubernetes_listener" {
  load_balancer_arn = aws_lb.kubernetes_lb.arn
  port              = 443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kubernetes_target_group.arn
  }
}

resource "aws_instance" "kubernetes_controllers" {
  count = 3
  ami           = "ami-xxxxxxxxxxxxxx" # Replace with the desired AMI ID
  instance_type = "t3.micro"
  key_name      = "kubernetes"
  subnet_id     = aws_subnet.kubernetes_subnet.id
  private_ip    = "10.0.1.1${count.index}"
  user_data = <<-EOF
              name=controller-${count.index}
              EOF
  root_block_device {
    volume_size = 50
  }
  tags = {
    Name = "controller-${count.index}"
  }
}

resource "aws_instance" "kubernetes_workers" {
  count = 3
  ami           = "ami-xxxxxxxxxxxxxx" # Replace with the desired AMI ID
  instance_type = "t3.micro"
  key_name      = "kubernetes"
  subnet_id     = aws_subnet.kubernetes_subnet.id
  private_ip    = "10.0.1.2${count.index}"
  user_data = <<-EOF
              name=worker-${count.index}|pod-cidr=10.200.${count.index}.0/24
              EOF
  root_block_device {
    volume_size = 50
  }
  tags = {
    Name = "worker-${count.index}"
  }
}

output "kubernetes_public_address" {
  value = aws_lb.kubernetes_lb.dns_name
}
