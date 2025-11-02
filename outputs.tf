output "load_balancer_dns" {
  value       = module.application.load_balancer_dns
  description = "ALB DNS name"
}
    