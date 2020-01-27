# ELB with HTTP and HTTPS

Create a basic Elastic Load Balancer with an HTTPS listeners and an SSL certificate. Whitelist enabled on the first listener.
All request on /api are redirected to another pool thanks to L7 policies and rules associated.

## Usage

Fil in the required parameters into `parameters.tfvars` (or create a new your-parameters-file.auto.tfvars that will be automatically used by Terraform -> no need to use -var-file= on the following commands)

Then run the Terraform commands:    

```bash
$ terraform init
$ terraform plan -var-file=parameters.tfvars
$ terraform apply -var-file=parameters.tfvars
```
