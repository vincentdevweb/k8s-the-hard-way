terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.16.2"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-3" # AWS region
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
  availability_zone       = "eu-west-3c" # Change this to your desired availability zone
  map_public_ip_on_launch = true         #public ip au lancement 
  tags = {
    Name = "kubernetes"
  }
}

#Internet gateway link of item VPC aws_vpc (passerelle)
resource "aws_internet_gateway" "kubernetes_igw" {
  vpc_id = aws_vpc.kubernetes_vpc.id
  tags = {
    Name = "kubernetes"
  }
}

#Table route for VPC
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

#Sécurity group
resource "aws_security_group" "kubernetes_security_group" {
  name        = "kubernetes"                # Nom du groupe de sécurité
  description = "Kubernetes security group" # Description du groupe de sécurité
  vpc_id      = aws_vpc.kubernetes_vpc.id   # ID de la VPC à associer au groupe de sécurité

  ingress {
    from_port   = 0                                # Port de début de la plage de ports autorisée
    to_port     = 65535                            # Port de fin de la plage de ports autorisée
    protocol    = "all"                            # Protocole autorisé (TCP dans ce cas)
    cidr_blocks = ["10.0.0.0/16", "10.200.0.0/16"] # Plages IP autorisées
  }

  ingress {
    from_port   = 22 # Autoriser le trafic SSH sur le port 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Autoriser depuis n'importe quelle adresse IP
  }

  ingress {
    from_port   = 6443 # Autoriser le trafic sur le port 6443 (Kubernetes)
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443 # Autoriser le trafic HTTPS sur le port 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1 # Autoriser le trafic ICMP (ping)
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


#load balancer
# resource "aws_lb" "kubernetes_lb" {
#   name               = "kubernetes"
#   internal           = false
#   load_balancer_type = "network"
#   subnets            = [aws_subnet.kubernetes_subnet.id]
# }

# #load balancer target group
# resource "aws_lb_target_group" "kubernetes_target_group" {
#   name     = "kubernetes"
#   port     = 6443
#   protocol = "TCP"
#   vpc_id   = aws_vpc.kubernetes_vpc.id
#   target_type = "ip"
# }

#load balancer listener
# resource "aws_lb_listener" "kubernetes_listener" {
#   load_balancer_arn = aws_lb.kubernetes_lb.arn
#   port              = 443
#   protocol          = "TCP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.kubernetes_target_group.arn
#   }
# }



# output "kubernetes_public_address" {
#   value = aws_lb.kubernetes_lb.dns_name
# }
