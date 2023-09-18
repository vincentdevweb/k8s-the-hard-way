# # Creation du load balancer pour le cluster
# resource "aws_lb" "kubernetes_lb" {
#   name               = "kubernetes"
#   internal           = false
#   load_balancer_type = "network"
#   subnets            = [aws_subnet.kubernetes_subnet.id]
#   tags = {
#     name = "lb_kubernetes"
#   }
# }

# #Load balancer pour un groupe cible crée
# resource "aws_lb_target_group" "kubernetes_target_group" {
#   name        = "kubernetes"
#   port        = 6443
#   protocol    = "TCP"
#   vpc_id      = aws_vpc.kubernetes_vpc.id
#   target_type = "ip"
#   tags = {
#     name = "lb_kubernetes_target"
#   }
# }

# # Création d'une cible pour le groupe
# resource "aws_lb_target_group_attachment" "kubernetes" {
#   count            = 1 # kubernetes_controllers_instance_count
#   target_group_arn = aws_lb_target_group.kubernetes_target_group.arn
#   target_id        = aws_instance.kubernetes_controllers[count.index].private_ip
#   port             = 6443
# }

# # Load balancer association avec le groupe cible
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

# # Récupération de l'adresse IP du load balancer
# data "aws_lb" "kubernetes" {
#   arn = aws_lb.kubernetes_lb.arn
# }