# # Création de la paire de clés AWS
# resource "aws_key_pair" "kubernetes_key" {
#   key_name   = "kubernetes"                                 # Le nom de la paire de clés AWS que vous souhaitez créer
#   public_key = file("C:/Users/Vincent/.ssh/kubernetes.pub") # Le chemin vers votre clé publique SSH
#   pem_key    = file("C:/Users/Vincent/.ssh/kubernetes.pem") # Le chemin vers votre fichier privée PEM
# }

resource "aws_key_pair" "kubernetes_key" {
  key_name   = "kubernetes-m2i-local"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6PdmNSlofAAbwGx92oIw1nKankUpKKCsT6cDbm8Ycq4e0i225vYKEYbWNNqNoQV9DOaidRciGFBfacF9d5zo9hgJadDgLIH9lNMJJThVtybNbcdqhxL5wOZViWFPTpIEYnMl2Q9kd6BK8lZi74etgxZruTX4bxuYATkI/2sLd/mHAxdgmIDt8qHrvhCcy4jKvYqptSdFxoBWxeTNVcwdsGtTMkwKda+12N4kxdEki7D3oZez2zmZzNI+m4XJpAE4VvEm+4Bd6TVwQMjJO7RjWulcimH3HitlE0NZFNgZEtLtj8u33v4ZaPm5h1IFIIBnMl78CTiA4insZZczVm0Yb"
}

#Instance Controllers
resource "aws_instance" "kubernetes_controllers" {
  count         = 1
  ami           = "ami-05b5a865c3579bbc4"
  instance_type = "t3.micro"
  key_name      = aws_key_pair.kubernetes_key.key_name
  subnet_id     = aws_subnet.kubernetes_subnet.id
  # Attachez le groupe de sécurité à cette instance
  vpc_security_group_ids = [aws_security_group.kubernetes_security_group.id]
  private_ip             = "10.0.1.1${count.index}"
  user_data              = <<-EOF
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
  count         = 1                                    # Créez N instances EC2 identiques
  ami           = "ami-05b5a865c3579bbc4"              # Remplacez par l'ID AMI de votre choix / Image
  instance_type = "t2.micro"                           # Type d'instance EC2
  key_name      = aws_key_pair.kubernetes_key.key_name # Nom de la clé SSH à utiliser
  subnet_id     = aws_subnet.kubernetes_subnet.id
  # Attachez le groupe de sécurité à cette instance
  vpc_security_group_ids = [aws_security_group.kubernetes_security_group.id]

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



