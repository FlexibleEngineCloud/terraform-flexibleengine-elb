terraform {
  required_version = ">= 0.12.0"
}

resource "flexibleengine_lb_loadbalancer_v2" "loadbalancer" {
  name          = "elb-${var.loadbalancer_name}"
  vip_subnet_id = var.subnet_id
  vip_address   = var.vip_address
}

resource "flexibleengine_networking_floatingip_v2" "loadbalancer_eip" {
  count      = var.bind_eip && var.eip_addr == null ? 1 : 0
  pool       = "admin_external_net"
  port_id    = flexibleengine_lb_loadbalancer_v2.loadbalancer.vip_port_id
  depends_on = [flexibleengine_lb_loadbalancer_v2.loadbalancer]
}

resource "flexibleengine_networking_floatingip_associate_v2" "loadbalancer_eip_attach" {
  count       = var.bind_eip && var.eip_addr != null ? 1 : 0
  floating_ip = var.eip_addr
  port_id     = flexibleengine_lb_loadbalancer_v2.loadbalancer.vip_port_id
}

resource "flexibleengine_lb_certificate_v2" "cert" {
  count       = var.cert && var.certId == null ? 1 : 0
  name        = var.cert_name
  domain      = var.domain
  private_key = var.private_key
  certificate = var.certificate
}

resource "flexibleengine_lb_listener_v2" "listeners" {
  count                     = length(var.listeners)
  name                      = "${var.loadbalancer_name}-${element(var.listeners.*.name, count.index)}"
  protocol                  = element(var.listeners.*.protocol, count.index)
  protocol_port             = element(var.listeners.*.port, count.index)
  loadbalancer_id           = flexibleengine_lb_loadbalancer_v2.loadbalancer.id
  default_tls_container_ref = var.cert && element(var.listeners.*.hasCert, count.index) && var.certId == null ? element(flexibleengine_lb_certificate_v2.cert.*.id, 0) : var.cert && element(var.listeners.*.hasCert, count.index) && var.certId != null ? var.certId : null
}

resource "flexibleengine_lb_pool_v2" "pools" {
  count           = length(var.pools)
  name            = var.pools[count.index].name
  protocol        = element(var.pools.*.protocol, count.index)
  lb_method       = element(var.pools.*.lb_method, count.index)
  listener_id     = var.pools[count.index].listener_index != null ? flexibleengine_lb_listener_v2.listeners[lookup(var.pools[count.index], "listener_index", count.index)].id : null
  loadbalancer_id = var.pools[count.index].listener_index == null ? flexibleengine_lb_loadbalancer_v2.loadbalancer.id : null
}

resource "flexibleengine_lb_member_v2" "members" {
  count         = length(var.backends)
  name          = "${flexibleengine_lb_pool_v2.pools[lookup(var.backends[count.index], "pool_index", count.index)].name}-${element(var.backends.*.name, count.index)}"
  address       = var.backends_addresses[var.backends[count.index].address_index]
  protocol_port = var.backends[count.index].port
  pool_id       = flexibleengine_lb_pool_v2.pools[lookup(var.backends[count.index], "pool_index", count.index)].id
  subnet_id     = var.backends[count.index].subnet_id
  depends_on    = [flexibleengine_lb_pool_v2.pools]
}

resource "flexibleengine_lb_monitor_v2" "monitor" {
  count       = length(var.monitors)
  name        = "${flexibleengine_lb_pool_v2.pools[lookup(var.monitors[count.index], "pool_index", count.index)].name}-${element(var.monitors.*.name, count.index)}"
  pool_id     = flexibleengine_lb_pool_v2.pools[lookup(var.monitors[count.index], "pool_index", count.index)].id
  type        = var.monitors[count.index].protocol
  delay       = var.monitors[count.index].delay
  timeout     = var.monitors[count.index].timeout
  max_retries = var.monitors[count.index].max_retries
  depends_on  = [flexibleengine_lb_pool_v2.pools, flexibleengine_lb_member_v2.members]
}

resource "flexibleengine_lb_monitor_v2" "monitor_http" {
  count          = length(var.monitorsHttp)
  name           = "${flexibleengine_lb_pool_v2.pools[lookup(var.monitorsHttp[count.index], "pool_index", count.index)].name}-${element(var.monitorsHttp.*.name, count.index)}"
  pool_id        = flexibleengine_lb_pool_v2.pools[lookup(var.monitorsHttp[count.index], "pool_index", count.index)].id
  type           = var.monitorsHttp[count.index].protocol
  delay          = var.monitorsHttp[count.index].delay
  timeout        = var.monitorsHttp[count.index].timeout
  max_retries    = var.monitorsHttp[count.index].max_retries
  depends_on     = [flexibleengine_lb_pool_v2.pools, flexibleengine_lb_member_v2.members]
  url_path       = var.monitorsHttp[count.index].url_path
  http_method    = var.monitorsHttp[count.index].http_method
  expected_codes = var.monitorsHttp[count.index].expected_codes
}

resource "flexibleengine_lb_whitelist_v2" "whitelists" {
  count            = length(var.listeners_whitelist)
  enable_whitelist = var.listeners_whitelist[count.index].enable_whitelist
  whitelist        = var.listeners_whitelist[count.index].whitelist
  listener_id      = flexibleengine_lb_listener_v2.listeners[lookup(var.listeners_whitelist[count.index], "listener_index", count.index)].id
}

resource "flexibleengine_lb_l7policy_v2" "l7policies" {
  count                = length(var.l7policies)
  name                 = var.l7policies[count.index].name
  action               = var.l7policies[count.index].action
  description          = var.l7policies[count.index].description
  position             = var.l7policies[count.index].position
  listener_id          = flexibleengine_lb_listener_v2.listeners[lookup(var.l7policies[count.index], "listener_index", count.index)].id
  redirect_listener_id = var.l7policies[count.index].redirect_listener_index != null ? flexibleengine_lb_listener_v2.listeners[lookup(var.l7policies[count.index], "redirect_listener_index", count.index)].id : null
  redirect_pool_id     = var.l7policies[count.index].redirect_pool_index != null ? flexibleengine_lb_pool_v2.pools[lookup(var.l7policies[count.index], "redirect_pool_index", count.index)].id : null
}

resource "flexibleengine_lb_l7rule_v2" "l7rules" {
  count        = length(var.l7policies_rules)
  l7policy_id  = flexibleengine_lb_l7policy_v2.l7policies[lookup(var.l7policies_rules[count.index], "l7policy_index", count.index)].id
  type         = var.l7policies_rules[count.index].type
  compare_type = var.l7policies_rules[count.index].compare_type
  value        = var.l7policies_rules[count.index].value
}


