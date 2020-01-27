provider "flexibleengine" {
  access_key  = "XXX"
  secret_key  = "XXX"
  tenant_name = var.tenant_name

  domain_name = var.domain_name
  auth_url    = var.endpoint
  region      = var.region
}
