#Instance Controllers
resource "aws_instance" "kubernetes_controllers" {
  count         = 3
  ami           = "ami-05b5a865c3579bbc4" 
  instance_type = "t2.micro"
  key_name      = "kubernetes"
  subnet_id     = aws_subnet.kubernetes_subnet.id
  private_ip    = "10.0.1.1${count.index}"
  user_data     = <<-EOF
              name=controller-${count.index}
              EOF
  root_block_device {
    volume_size = 30
  }
  tags = {
    Name = "controller-${count.index}"
  }

}

#Instances Workers
resource "aws_instance" "kubernetes_workers" {
  count         = 3                                      # Créez N instances EC2 identiques
  ami           = "ami-05b5a865c3579bbc4"                # Remplacez par l'ID AMI de votre choix
  instance_type = "t2.micro"                             # Type d'instance EC2
  key_name      = "kubernetes"                           # Nom de la clé SSH à utiliser
  subnet_id     = aws_subnet.kubernetes_subnet.id        # ID du sous-réseau où les instances seront lancées

  # Configuration des adresses IP privées pour chaque instance
  private_ip    = "10.0.1.2${count.index}"               

  # UserData est un script qui sera exécuté lors du lancement de chaque instance
  user_data     = <<-EOF
              name=worker-${count.index}|pod-cidr=10.200.${count.index}.0/24
              EOF
  # Taille du volume principal en Go
  root_block_device {
    volume_size = 30                                     
  }

  # Tags pour identifier chaque instance EC2
  tags = {
    Name = "worker-${count.index}"                       
  }
}



