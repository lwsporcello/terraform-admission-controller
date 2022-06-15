<a href="https://lacework.com"><img src="https://techally-content.s3-us-west-1.amazonaws.com/public-content/lacework_logo_full.png" width="600"></a>

# terraform-admission-controller
A Terraform Module to create a Deployment for deploying the Lacework Admission Controller (and optionally Proxy Scanner) in a Kubernetes cluster.

## Kubernetes

The `main.tf` file will configure a Kubernetes Deployment which will then be used to run the Lacework Admission Controller pod in a cluster. Optionally, a second deployment can be created to deploy the Lacework Proxy Scanner, a required component for the Admission Controller. 

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.31 |
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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| [revision_history_limit](#revision\_history\_limit) | The number of history revisions to keep | `number` | `10` | no |
| [service_account_name](#service\_account\_name) | The name of the Kubernetes ServiceAccount to create for pods | `string` | `lacework-admission-controller` | no |
| [image_pull_policy](#image\_pull\_policy) | The pull policy to use when deploying container images. Ex: Always, Never, IfNotPresent | `string` | `Always` | no |
| [tolerations](#tolerations) | A list of Kubernetes Tolerations to apply to the Deployment definition | `list(map(string))` | `[{ key = "node-role.kubernetes.io/master", effect = "NoSchedule" }]` | no |
| [namespace](#namespace) | The Kubernetes namespace in which to deploy the admission controller and (optionally) the proxy scanner | `string` | `lacework` | no |
| [deploy_combined](#deploy\_combined) | Deploy both the admission controller and proxy scanner together if true. If false, only deploy the admission controller | `bool` | `true` | no |
| [admission_controller_name](#admission\_controller\_name) | The name for the Lacework admission controller deployment | `string` | `lacework-admission-controller` | no |
| [admission_controller_image](#admission\_controller\_image) | The image to use for deploying the Lacework admission controller | `string` | `lacework/lacework-admission-controller` | no |
| [admission_controller_image_tag](#admission\_controller\_image\_tag) | The image tag to use for deploying the Lacework admission controller | `string` | `latest` | no |
| [certs_secret_name](#certs\_secret\_name) | The name of the K8s secret containing the certificates | `string` | `lacework-admission-certs` | no |
| [use_self_signed_certs](#use\_self\_signed\_certs) | Deploy admission controller with self-signed certificates if true. If false, you must define certs in the ca_cert, server_certificate, and server_key variables | `bool` | `true` | no |
| [enable_debug_logging](#enable\_debug\_logging) | Enable debug logging on the admission controller | `bool` | `true` | no |
| [tls_port](#tls\_port) | Listening port for the admission controller | `number` | `8443` | no |
| [cert_file_path](#cert\_file\_path) | Path for server certificate file in admission controller volume | `string` | `/certs/admission.crt` | no |
| [cert_key_path](#cert\_key\_path) | Path for server key file in admission controller volume | `string` | `/certs/admission.key` | no |
| [failure_policy](#failure\_policy) | Webhook falure policy (what response the webhook should take if it fails) Ex: Ignore, Fail | `string` | `Ignore` | no |
| [webhook_timeout](#webhook\_timeout) | Timeout in seconds for admission webhook failure | `number` | `30` | no |
| [excluded_resources](#excluded\_resources) | The list of resources skip admission review. Ex: ['Pod', 'Deployment', 'ReplicaSet', 'DaemonSet'] | `list(string)` | `[]` | no |
| [bypass_scope](#bypass\_scope) | The list of namespaces to bypass control of by admission controller. Ex: kube-system,kube-public,lacework,mynamespace | `string` | `kube-system,kube-public,lacework,lacework-dev` | no |
| [block_exec](#block\_exec) | Block command execution (kubectl exec) on pods by admission controller | `bool` | `false` | no |
| [admission_scanner_timeout](#admission\_scanner\_timeout) | Default timeout for communication between admission controller and proxy scanner | `number` | `30` | no |
| [skip_verify](#skip\_verify) | Skip SSL verification between the webhook and the proxy scanner | `bool` | `true` | no |
| [default_registry](#default\_registry) | Default registry for proxy scanner to use when none is provided in image name | `string` | `index.docker.io` | no |
| [block_on_error](#block\_on\_error) | Block admission request if proxy scanner returns and error | `bool` | `false` | no |
| [ca_cert](#ca\_cert) | Root certificate for TLS authentication with the K8s api server. If use_self_signed_certs is false, this is required. Otherwise a self-signed cert will be created. | `string` | `""` | no |
| [server_certificate](#server\_certificate) | Certificate for TLS authentication with the K8s api server. If use_self_signed_certs is false, this is required. Otherwise a self-signed cert will be created. | `string` | `""` | no |
| [server_key](#server\_key) | Certificate key for TLS authentication with the K8s api server. If use_self_signed_certs is false, this is required. Otherwise a self-signed cert will be created. | `string` | `""` | no |
| [proxy_scanner_name](#proxy\_scanner\_name) | The name for the Lacework proxy scanner deployment | `string` | `lacework-proxy-scanner` | no |
| [proxy_scanner_image](#proxy\_scanner\_image) | The image to use for deploying the Lacework proxy scanner | `string` | `lacework/lacework-proxy-scanner` | no |
| [proxy_scanner_image_tag](#proxy\_scanner\_image\_tag) | The image tag to use for deploying the Lacework proxy scanner | `string` | `latest` | no |
| [proxy_scanner_log_level](#proxy\_scanner\_log\_level) | Set the LOG_LEVEL environment variable for proxy scanner. Ex: info, debug | `string` | `info` | no |
| [proxy_scanner_token](#proxy\_scanner\_token) | The token for the Lacework proxy scanner | `string` | | yes |
| [lacework_account_name](#lacework\_account\_name) | The name of your Lacework account (for the proxy scanner). | `string` | | yes |
| [static_cache_location](#static\_cache\_location) | Location of the proxy scanner's cache file | `string` | `/opt/lacework/cache` | no |
| [scan_public_registries](#scan\_public\_registries) | Set to true if you want to scan images from registries that are publicly accessible | `bool` | `false` | no |
| [registries](#registries) | A list of registries to apply to proxy scanner. See proxy scanner configuration documentation for details | `list(any)` | | yes |
