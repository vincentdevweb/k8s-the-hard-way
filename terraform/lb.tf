
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
