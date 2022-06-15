<a href="https://lacework.com"><img src="https://techally-content.s3-us-west-1.amazonaws.com/public-content/lacework_logo_full.png" width="600"></a>

# terraform-admission-controller
A Terraform Module to create a Deployment for deploying the Lacework Admission Controller (and optionally Proxy Scanner) in a Kubernetes cluster.

## Kubernetes

The `main.tf` file will configure a Kubernetes Deployment which will then be used to run the Lacework Admission Controller pod in a cluster. Optionally, a second deployment can be created to deploy the Lacework Proxy Scanner, a required component for the Admission Controller. 

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.31 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.0.0 |

## Resources

| Name | Type |
|------|------|
| [kubernetes_deployment.lacework_admission_controller](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_secret.lacework_admission_controller_config](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.lacework_admission_controller_certs](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_role.lacework_admission_controller_role](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role) | resource |
| [kubernetes_role_binding.lacework_admission_controller_role_binding](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_binding) | resource |
| [kubernetes_cluster_role.lacework_admission_controller_cluster_role](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role_binding.lacework_admission_controller_cluster_role_binding](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_service.lacework_admission_controller_service](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [kubernetes_service_account.lacework_admission_controller_service_account](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_validating_webhook_configuration_v1.lacework_admission_controller_webhook](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/validating_webhook_configuration_v1) | resource |
| [kubernetes_deployment.lacework_proxy_scanner](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_secret.lacework_proxy_scanner_config](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_service.lacework_proxy_scanner_service](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [tls_private_key.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |
| [tls_private_key.admission](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_cert_request.admission](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/cert_request) | resource |
| [tls_locally_signed_cert.admission](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/locally_signed_cert) | resource |
