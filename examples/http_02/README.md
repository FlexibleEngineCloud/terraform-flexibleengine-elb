# ELB with HTTP and HTTPS with L7 Policy usage

Create an Elastic Load Balancer with an HTTP/HTTPS (with SSL certificate) listeners, with a permanent redirect HTTP to HTTPS.

## Usage

Fil in the required parameters into `parameters.tfvars` (or create a new your-parameters-file.auto.tfvars that will be automatically used by Terraform -> no need to use -var-file= on the following commands)

Then run the Terraform commands:

```bash
$ terraform init
$ terraform plan -var-file=parameters.tfvars
$ terraform apply -var-file=parameters.tfvars
```
