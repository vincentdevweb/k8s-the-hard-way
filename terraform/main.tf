terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.17"
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
  cidr_block           = "10.0.0.0/16" # 10.0.X.X
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "kubernetes"
  }
}

#On link of item VPC for subnet --- SUBNET
resource "aws_subnet" "kubernetes_subnet" {
  vpc_id                  = aws_vpc.kubernetes_vpc.id
  cidr_block              = "10.0.1.0/24" # 10.0.1.X
  availability_zone       = "eu-west-3c"  # Change this to your desired availability zone
  map_public_ip_on_launch = true          #public ip au lancement 
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

# Associe sous réseaux et la table de routage 
resource "aws_route_table_association" "kubernetes" {
  subnet_id      = aws_subnet.kubernetes_subnet.id
  route_table_id = aws_route_table.kubernetes_route_table.id
}

#Création d'un groupe de sécurité 
resource "aws_security_group" "kubernetes_security_group" {
  name        = "kubernetes"                # Nom du groupe de sécurité
  description = "Kubernetes security group" # Description du groupe de sécurité
  vpc_id      = aws_vpc.kubernetes_vpc.id   # ID de la VPC à associer au groupe de sécurité

}

#Ajoute une régle spécifique à un groupe de sécuriter 
resource "aws_security_group_rule" "kubernetes_rule_one" {
  type              = "egress"
  from_port         = 0                                               # Port de début de la plage de ports autorisée
  to_port           = 0                                               # Port de fin de la plage de ports autorisée
  protocol          = "-1"                                            # Protocole autorisé (all dans ce cas)
  cidr_blocks       = ["0.0.0.0/0"]                                   # Plages IP autorisées
  security_group_id = aws_security_group.kubernetes_security_group.id # ID du group de sécu

}
resource "aws_security_group_rule" "kubernetes_rule_two" {
  type              = "ingress"
  from_port         = -1                               # Port de début de la plage de ports autorisée
  to_port           = -1                               # Port de fin de la plage de ports autorisée
  protocol          = "-1"                             # Protocole autorisé ( "-1" = all dans ce cas)
  cidr_blocks       = ["10.0.0.0/16", "10.200.0.0/16"] # Plages IP autorisées
  security_group_id = aws_security_group.kubernetes_security_group.id

}
resource "aws_security_group_rule" "kubernetes_rule_three" {
  type              = "ingress"
  from_port         = 22 # Autoriser le trafic SSH sur le port 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # Autoriser depuis n'importe quelle adresse IP
  security_group_id = aws_security_group.kubernetes_security_group.id

}
resource "aws_security_group_rule" "kubernetes_rule_for" {
  type              = "ingress"
  from_port         = 6443 # Autoriser le trafic sur le port 6443 (Kubernetes)
  to_port           = 6443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.kubernetes_security_group.id

}

resource "aws_security_group_rule" "kubernetes_rule_five" {
  type              = "ingress"
  from_port         = 443 # Autoriser le trafic HTTPS sur le port 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.kubernetes_security_group.id

}

resource "aws_security_group_rule" "kubernetes_rule_six" {
  type              = "ingress"
  from_port         = -1 # Autoriser le trafic ICMP (ping)
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.kubernetes_security_group.id
}



