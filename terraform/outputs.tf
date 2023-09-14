output "kubernetes_public_address_ip_controllers" {
  value = [for instance in aws_instance.kubernetes_controllers : instance.public_ip]
}

output "kubernetes_public_address_ip_workers" {
  value = [for instance in aws_instance.kubernetes_workers : instance.public_ip]
}