output "id" {
  description = "The LB ID"
  value       = flexibleengine_lb_loadbalancer_v2.loadbalancer.id
}

output "public_ip" {
  description = "The LB public IP"
  value       = var.bind_eip ? var.eip_addr == null ? flexibleengine_networking_floatingip_v2.loadbalancer_eip[0].address : var.eip_addr : null
}

output "private_ip" {
  description = "The LB private IP"
  value       = flexibleengine_lb_loadbalancer_v2.loadbalancer.vip_address
}

output "pools" {
  description = "The LB pools"
  value       = [for pool in flexibleengine_lb_pool_v2.pools : { id = pool.id, name = pool.name }]
}
