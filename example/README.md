# Prisma Cloud Defender deployment on a ECS (EC2) Cluster

Configuration in this directory creates:
- AWS VPC and subnets
- AWS ECS cluster using autoscaling group capacity provider
- AWS Secrets Manager secrets for storing INSTALL_BUNDLE and Registry token
- IAM roles
- Prisma Cloud Defender ECS task definition
- Prisma Cloud Defender ECS service

Defender INSTALL_BUNDLE, Prisma Cloud registry (registry.twistlock.com) token, and WS_ADDRESS are retrieved using the Terraform http data source.

## How to deploy this example

1. Clone the repository and `cd example`
   
2. Modify vaules in `terraform.tfvars` if required.

3. Log in to Prisma Cloud console and go to ***Compute -> System -> Utilities***, copy the value from ***"Path to Console"*** and ***"API Token"***.
You will need to pass those values to `console_address`, `api_token` variables during `terraform plan` and `terraform apply`

4. Execute:

```bash
$ export CONSOLE_ADDRESS=<console_address>
$ export API_TOKEN=<api_token>
$
$ terraform init
$ terraform plan -var="console_address=$CONSOLE_ADDRESS" -var="api_token=$API_TOKEN"
$ terraform apply -var="console_address=$CONSOLE_ADDRESS" -var="api_token=$API_TOKEN"
```
Note that this example may create resources which will incur monetary charges on your AWS bill. Run `terraform destroy` when you no longer need these resources.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.6 |
| <a name="requirement_http"></a> [http](#requirement\_http) | >= 3.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.6 |
| <a name="provider_http"></a> [http](#provider\_http) | >= 3.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_autoscaling"></a> [autoscaling](#module\_autoscaling) | terraform-aws-modules/autoscaling/aws | ~> 6.5 |
| <a name="module_autoscaling_sg"></a> [autoscaling\_sg](#module\_autoscaling\_sg) | terraform-aws-modules/security-group/aws | ~> 4.0 |
| <a name="module_ecs"></a> [ecs](#module\_ecs) | terraform-aws-modules/ecs/aws | n/a |
| <a name="module_prisma_cloud_defender"></a> [prisma\_cloud\_defender](#module\_prisma\_cloud\_defender) | ../ | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 3.16.0 |

## Resources

| Name | Type |
|------|------|
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_ssm_parameter.ecs_optimized_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [http_http.defender_image](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |
| [http_http.install_bundle](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_token"></a> [api\_token](#input\_api\_token) | Prisma Cloud CWP/Compute API token | `string` | n/a | yes |
| <a name="input_autoscalling_desired_capacity"></a> [autoscalling\_desired\_capacity](#input\_autoscalling\_desired\_capacity) | ECS Autoscalling desired capacity | `number` | `2` | no |
| <a name="input_autoscalling_max_size"></a> [autoscalling\_max\_size](#input\_autoscalling\_max\_size) | ECS Autoscalling max size | `number` | `3` | no |
| <a name="input_autoscalling_min_size"></a> [autoscalling\_min\_size](#input\_autoscalling\_min\_size) | ECS Autoscalling min size | `number` | `1` | no |
| <a name="input_console_address"></a> [console\_address](#input\_console\_address) | Prisma Cloud CWP/Compute console address | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The type of ECS instances | `string` | `"t3.medium"` | no |
| <a name="input_name"></a> [name](#input\_name) | Deployment Name | `string` | `"prisma-cloud-defender"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"eu-west-1"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to resources | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->