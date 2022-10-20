# terraform-prisma-cloud-defender-ecs
Terraform Module for Prisma Cloud Defender deployment on AWS ECS

## Usage

```hcl
module "prisma-cloud-defender" {
  source                      = "github.com/hasitha-u/terraform-prisma-cloud-defender-ecs"
  name                        = "prisma-cloud-defender"
  ecs_cluster_arn             = module.ecs.cluster_arn
  defender_install_bundle     = var.install_bundle #<-Sensitive data
  defender_memory             = 500
  defender_image              = "registry.twistlock.com/twistlock/defender:defender_22_06_213"
  prisma_cloud_registry_token = var.registry_token  #<-Sensitive data
  prisma_cloud_ws_address     = "wss://us-east1.cloud.twistlock.com:443" #Compute/CWP console address
  tags = {
    Environment = "Development"
    Project     = "Test"
  }

}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.6 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.6 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecs_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.ecs_task_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.password_policy_secretsmanager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_secretsmanager_secret.prisma_cloud_install_bundle](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.prisma_cloud_registry_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.prisma_cloud_install_bundle](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.prisma_cloud_registry_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [random_string.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_defender_image"></a> [defender\_image](#input\_defender\_image) | Prisma Cloud Defender Image | `string` | n/a | yes |
| <a name="input_defender_install_bundle"></a> [defender\_install\_bundle](#input\_defender\_install\_bundle) | Prisma Cloud Defender INSTALL\_BUNDLE | `string` | n/a | yes |
| <a name="input_defender_memory"></a> [defender\_memory](#input\_defender\_memory) | Memory (in MiB) for the Defender task | `string` | n/a | yes |
| <a name="input_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#input\_ecs\_cluster\_arn) | ARN of the ECS cluster | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Defender Deployment name | `string` | `"prisma-cloud-defender"` | no |
| <a name="input_prisma_cloud_registry_token"></a> [prisma\_cloud\_registry\_token](#input\_prisma\_cloud\_registry\_token) | Prisma Cloud registry (registry.twistlock.com) access token | `string` | n/a | yes |
| <a name="input_prisma_cloud_ws_address"></a> [prisma\_cloud\_ws\_address](#input\_prisma\_cloud\_ws\_address) | Websocket address for the Prisma Cloud CWP console (Ex: wss://us-east1.cloud.twistlock.com:443) | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to resources | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
