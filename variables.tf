variable "loadbalancer_name" {
  description = "Name of the Load Balancer (It is already prefixed by elb-*)"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID to attach the VIP"
  type        = string
}

variable "vip_address" {
  description = "Address of the VIP (In the same Subnet)"
  type        = string
}

variable "bind_eip" {
  description = "Boolean to know if we bind an EIP"
  type        = bool
  default     = true
}

variable "eip_addr" {
  description = "Address of an existing EIP to attach (ex: 1.2.3.4). Left null will create a new EIP"
  type        = string
  default     = null
}

variable "cert" {
  description = "Boolean to know if we add certificate"
  type        = bool
  default     = false
}

variable "cert_name" {
  default = ""
}

variable "certId" {
  default = ""
}

variable "private_key" {
  default = ""
}

variable "certificate" {
  default = ""
}

variable "domain" {
  default = ""
}


variable "listeners" {
  description = "Listeners list"
  type = list(object({
    name     = string
    port     = number
    protocol = string #Protocol used TCP, UDP, HTTP or TERMINATED_HTTPS
    hasCert  = bool
  }))
}

variable "listeners_whitelist" {
  description = "Listeners whitelist"
  type = list(object({
    listeners_index  = number
    enable_whitelist = bool
    whitelist        = string #Comma separated : "192.168.11.1,192.168.0.1/24,192.168.201.18/8"
  }))
}

variable "pools" {
  description = "Pools list"
  type = list(object({
    name           = string
    protocol       = string
    lb_method      = string # Load Balancing method (ROUND_ROBIN recommended)
    listener_index = number # Listenerused in this pool (Can be null)
  }))
}

variable "backends" {
  description = "List of backends"
  type = list(object({
    name          = string
    port          = number
    address_index = string
    pool_index    = number
    subnet_id     = string
  }))
}

variable "backends_addresses" {
  description = "List of backends adresses"
  type        = list
}

variable "monitors" {
  description = "List of monitors"
  type = list(object({
    name        = string
    pool_index  = number
    protocol    = string
    delay       = number
    timeout     = number
    max_retries = number
  }))
  default = []
}

variable "monitorsHttp" {
  description = "List of monitors HTTP/HTTPS"
  type = list(object({
    name           = string
    pool_index     = number
    protocol       = string
    delay          = number
    timeout        = number
    max_retries    = number
    url_path       = string
    http_method    = string
    expected_codes = string
  }))
  default = []
}

variable "l7policies" {
  description = "List of L7 policies redirected to pools/listeners"
  type = list(object({
    name                    = string
    action                  = string # REDIRECT_TO_POOL / REDIRECT_TO_LISTENER
    description             = string
    position                = number
    listener_index          = number
    redirect_listener_index = number # if REDIRECT_TO_LISTENER is set, or null LISTENER must be listen on HTTPS_TERMINATED
    redirect_pool_index     = number # if REDIRECT_TO_POOL is set, or null - pool used to redirect must be not associated with a listener
  }))
  default = []
}

variable "l7policies_rules" { # Only if REDIRECT_TO_POOL
  description = "List of L7 policies redirected to pools/listeners"
  type = list(object({
    l7policy_index = number
    type           = string
    compare_type   = string
    value          = string
  }))
  default = []
}
