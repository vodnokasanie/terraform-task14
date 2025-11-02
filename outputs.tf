output "load_balancer_dns" {
  value       = module.app.load_balancer_dns
  description = "ALB DNS name"
}
    