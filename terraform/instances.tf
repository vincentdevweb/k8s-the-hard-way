# # Création de la paire de clés AWS
# resource "aws_key_pair" "kubernetes_key" {
#   key_name   = "kubernetes"                                 # Le nom de la paire de clés AWS que vous souhaitez créer
#   public_key = file("C:/Users/Vincent/.ssh/kubernetes.pub") # Le chemin vers votre clé publique SSH
#   pem_key    = file("C:/Users/Vincent/.ssh/kubernetes.pem") # Le chemin vers votre fichier privée PEM
# }

#Instance Controllers
resource "aws_instance" "kubernetes_controllers" {
  count         = 1
  ami           = "ami-05b5a865c3579bbc4"
  instance_type = "t3.micro"
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

  # Copie de la clé SSH sur les instances controllers
  provisioner "file" {
    source      = "C:/Users/Vincent/.ssh/kubernetes.pem" # Chemin de votre clé privee SSH
    destination = "/home/ec2-user/.ssh/authorized_keys"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/ec2-user/.ssh/authorized_keys",
      "chmod 700 /home/ec2-user/.ssh",
      "sudo apt update",
      "sudo apt install -y ansible"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"                                       # Remplacez par l'utilisateur SSH approprié
    private_key = file("C:/Users/Vincent/.ssh/kubernetes.pem")     # Chemin de votre clé privée SSH sur votre machine locale
    host        = self.public_ip # Utilisez self.public_ip pour obtenir l'adresse IP publique de l'instance
  }
  
}




#Instances Workers
resource "aws_instance" "kubernetes_workers" {
  count         = 1                               # Créez N instances EC2 identiques
  ami           = "ami-05b5a865c3579bbc4"         # Remplacez par l'ID AMI de votre choix / Image
  instance_type = "t3.micro"                      # Type d'instance EC2
  key_name      = "kubernetes"                    # Nom de la clé SSH à utiliser
  subnet_id     = aws_subnet.kubernetes_subnet.id # ID du sous-réseau où les instances seront lancées

  # Configuration des adresses IP privées pour chaque instance
  private_ip = "10.0.1.2${count.index}"

  # UserData est un script qui sera exécuté lors du lancement de chaque instance
  user_data = <<-EOF
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



