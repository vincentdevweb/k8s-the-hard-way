#Instance Controllers
resource "aws_instance" "kubernetes_controllers" {
  count         = 3
  ami           = "ami-05b5a865c3579bbc4" # Replace with the desired AMI ID
  instance_type = "t2.micro"
  key_name      = "kubernetes"
  subnet_id     = aws_subnet.kubernetes_subnet.id
  private_ip    = "10.0.1.1${count.index}"
  user_data     = <<-EOF
              name=controller-${count.index}
              EOF
  root_block_device {
    volume_size = 50
  }
  tags = {
    Name = "controller-${count.index}"
  }

}


#Instances Workers
resource "aws_instance" "kubernetes_workers" {
  count         = 3
  ami           = "ami-05b5a865c3579bbc4" # Replace with the desired AMI ID
  instance_type = "t2.micro"
  key_name      = "kubernetes"
  subnet_id     = aws_subnet.kubernetes_subnet.id
  private_ip    = "10.0.1.2${count.index}"
  user_data     = <<-EOF
              name=worker-${count.index}|pod-cidr=10.200.${count.index}.0/24
              EOF
  root_block_device {
    volume_size = 50
  }
  tags = {
    Name = "worker-${count.index}"
  }

}


