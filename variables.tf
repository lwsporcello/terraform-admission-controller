#general parameters
variable "revision_history_limit" {
  type        = number
  description = "The number of history revisions to keep."
  default     = 10
}

variable "service_account_name" {
  type        = string
  description = "The Kubernetes ServiceAccount to use for pods."
  default     = "lacework-admission-sa"
}

variable "image_pull_policy" {
  type        = string
  description = "The pull policy to use when deploying container images. Ex: Always, Never, IfNotPresent"
  default     = "Always"
}

variable "tolerations" {
  type        = list(map(string))
  description = "A list of Kubernetes Tolerations to apply to the Deployment definition."
  default     = [{ key = "node-role.kubernetes.io/master", effect = "NoSchedule" }]
}

variable "namespace" {
  type        = string
  description = "The Kubernetes namespace in which to deploy the admission controller and (optionally) the proxy scanner."
  default     = "lacework"
}

variable "deploy_combined" {
  type        = bool
  description = "Deploy both the admission controller and proxy scanner together if true. If false, only deploy the admission controller."
  default     = true
}

#admission controller parameters
variable "admission_controller_name" {
  type        = string
  description = "The name for the Lacework admission controller deployment."
  default     = "lacework-admission-controller"
}

variable "admission_controller_image" {
  type        = string
  description = "The image to use for deploying the Lacework admission controller."
  default     = "lacework/lacework-admission-controller"
}

variable "admission_controller_image_tag" {
  type        = string
  description = "The image tag to use for deploying the Lacework admission controller."
  default     = "latest"
}

variable "certs_secret_name" {
  type        = string
  description = "The name of the K8s secret containing the certificates."
  default     = "lacework-admission-certs"
}

variable "use_self_signed_certs" {
  type        = bool
  description = "Deploy admission controller with self-signed certificates if true. If false, you must define certs in the ca_cert, server_certificate, and server_key variables."
  default     = true
}

variable "enable_debug_logging" {
  type        = bool
  description = "Enable debug logging on the admission controller."
  default     = true
}

variable "tls_port" {
  type        = number
  description = "Listening port for admission controller."
  default     = 8443
}

variable "cert_file_path" {
  type        = string
  description = "Path for server certificate file in admission controller volume."
  default     = "/certs/admission.crt"
}

variable "cert_key_path" {
  type        = string
  description = "Path for server key file in admission controller volume."
  default     = "/certs/admission.key"
}

variable "failure_policy" {
  type        = string
  description = "Webhook falure policy (what response the webhook should take if it fails) Ex: Ignore, Fail"
  default     = "Ignore"
}

variable "webhook_timeout" {
  type        = number
  description = "Timeout in seconds for admission webhook failure."
  default     = 30
}

variable "excluded_resources" {
  type        = list(string)
  description = "The list of resources skip admission review. Ex: ['Pod', 'Deployment', 'ReplicaSet', 'DaemonSet']"
  default     = []
}

variable "bypass_scope" {
  type        = string
  description = "The list of namespaces to bypass control of by admission controller. Ex: kube-system,kube-public,lacework,mynamespace"
  default     = "kube-system,kube-public,lacework,lacework-dev"
}

variable "block_exec" {
  type        = bool
  description = "Block command execution (kubectl exec) on pods by admission controller."
  default     = false
}

variable "admission_scanner_timeout" {
  type        = number
  description = "Default timeout for communication between admission controller and proxy scanner."
  default     = 30
}

variable "skip_verify" {
  type        = bool
  description = "Skip SSL verification between the webhook and the proxy scanner."
  default     = true
}

variable "default_registry" {
  type        = string
  description = "Default registry for proxy scanner to use when none is provided in image name."
  default     = "index.docker.io"
}

variable "block_on_error" {
  type        = bool
  description = "Block admission request if proxy scanner returns and error."
  default     = false
}

#certificate parameters
variable "ca_cert" {
  type        = string
  description = "Root certificate for TLS authentication with the K8s api server. If use_self_signed_certs is false, this is required. Otherwise a self-signed cert will be created."
  default     = ""
}

variable "server_certificate" {
  type        = string
  description = "Certificate for TLS authentication with the K8s api server. If use_self_signed_certs is false, this is required. Otherwise a self-signed cert will be created."
  default     = ""
}

variable "server_key" {
  type        = string
  description = "Certificate key for TLS authentication with the K8s api server. If use_self_signed_certs is false, this is required. Otherwise a self-signed cert will be created."
  default     = ""
}

#proxy scanner parameters
variable "proxy_scanner_name" {
  type        = string
  description = "The name for the Lacework proxy scanner deployment."
  default     = "lacework-proxy-scanner"
}

variable "proxy_scanner_image" {
  type        = string
  description = "The image to use for deploying the Lacework proxy scanner."
  default     = "lacework/lacework-proxy-scanner"
}

variable "proxy_scanner_image_tag" {
  type        = string
  description = "The image tag to use for deploying the Lacework proxy scanner."
  default     = "latest"
}

variable "proxy_scanner_log_level" {
  type        = string
  description = "Set the LOG_LEVEL environment variable for proxy scanner. Ex: info, debug"
  default     = "info"
}

variable "proxy_scanner_token" {
  type        = string
  description = "The token for the Lacework proxy scanner."
}

variable "lacework_account_name" {
  type        = string
  description = "The name of your Lacework account (for the proxy scanner)."
}

variable "static_cache_location" {
  type        = string
  description = "Location of the proxy scanner's cache file."
  default     = "/opt/lacework/cache"
}

variable "scan_public_registries" {
  type        = bool
  description = "Set to true if you want to scan images from registries that are publicly accessible."
  default     = false
}

variable "registries" {
  type        = list(any)
  description = "A list of registries to apply to proxy scanner. See proxy scanner configuration documentation for details."
}
