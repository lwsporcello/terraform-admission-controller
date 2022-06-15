resource "kubernetes_deployment" "lacework_admission_controller" {
  metadata {
    name      = var.admission_controller_name
    namespace = var.namespace
  }
  spec {
    revision_history_limit = var.revision_history_limit
    replicas               = 1

    selector {
      match_labels = {
        name = "lacework"
      }
    }

    template {
      metadata {
        labels = {
          name = "lacework"
          app  = var.admission_controller_name
        }
      }

      spec {
        dynamic "toleration" {
          for_each = var.tolerations
          content {
            key      = lookup(toleration.value, "key", "")
            operator = lookup(toleration.value, "operator", "Equal")
            value    = lookup(toleration.value, "operator", "Equal") == "Exists" ? "" : lookup(toleration.value, "value", "")
            effect   = lookup(toleration.value, "effect", "")
          }
        }

        service_account_name = var.service_account_name

        container {
          name              = var.admission_controller_name
          image             = join(":", [var.admission_controller_image, var.admission_controller_image_tag])
          image_pull_policy = var.image_pull_policy
          port {
            container_port = 8443
          }
          liveness_probe {
            initial_delay_seconds = 5
            period_seconds        = 5
            http_get {
              scheme = "HTTPS"
              path   = "/healthz"
              port   = 8443
            }
          }
          volume_mount {
            name       = "certs"
            mount_path = "/certs"
            read_only  = true
          }
          volume_mount {
            name       = "lacework-admission-volume"
            mount_path = "/config"
            read_only  = true
          }
        }
        volume {
          name = "certs"
          secret {
            secret_name = var.certs_secret_name
          }
        }
        volume {
          name = "lacework-admission-volume"
          secret {
            secret_name = var.admission_controller_name
          }
        }
      }
    }
  }
}

resource "kubernetes_secret" "lacework_admission_controller_config" {
  metadata {
    name      = var.admission_controller_name
    namespace = var.namespace
  }
  data = local.ac_config
}

resource "kubernetes_secret" "lacework_admission_controller_cert" {
  metadata {
    name      = var.certs_secret_name
    namespace = var.namespace
  }
  data = {
    "ca.crt"        = var.use_self_signed_certs ? tls_self_signed_cert.ca[0].cert_pem : file(var.ca_cert)
    "admission.key" = var.use_self_signed_certs ? tls_private_key.admission[0].private_key_pem : file(var.server_key)
    "admission.crt" = var.use_self_signed_certs ? tls_locally_signed_cert.admission[0].cert_pem : file(var.server_certificate)
  }
}

resource "kubernetes_role" "lacework_admission_controller_role" {
  metadata {
    name      = var.admission_controller_name
    namespace = var.namespace
  }
  rule {
    api_groups = ["*"]
    resources  = ["pods/log"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["*"]
    resources  = ["jobs"]
    verbs      = ["create", "delete"]
  }
}

resource "kubernetes_role_binding" "lacework_admission_controller_role_binding" {
  metadata {
    name      = var.admission_controller_name
    namespace = var.namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = var.admission_controller_name
  }
  subject {
    kind      = "ServiceAccount"
    name      = var.service_account_name
    namespace = var.namespace
  }
}

resource "kubernetes_cluster_role" "lacework_admission_controller_cluster_role" {
  metadata {
    name = var.admission_controller_name
  }
  rule {
    api_groups = ["*"]
    resources  = ["pods", "nodes", "namespaces", "deployments", "statefulsets", "jobs", "cronjobs", "daemonsets", "replicasets", "replicationcontrollers", "clusterroles", "clusterrolebindings", "componentstatuses"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["*"]
    resources  = ["secrets"]
    verbs      = ["get", "list", "watch", "update", "create"]
  }
}

resource "kubernetes_cluster_role_binding" "lacework_admission_controller_cluster_role_binding" {
  metadata {
    name = var.admission_controller_name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = var.admission_controller_name
  }
  subject {
    kind      = "ServiceAccount"
    name      = var.service_account_name
    namespace = var.namespace
  }
}

resource "kubernetes_service" "lacework_admission_controller_service" {
  metadata {
    name      = var.admission_controller_name
    namespace = var.namespace
    labels = {
      role = var.admission_controller_name
    }
  }
  spec {
    port {
      port        = 443
      target_port = 8443
    }
    selector = {
      app = var.admission_controller_name
    }
  }
}

resource "kubernetes_service_account" "lacework_admission_controller_service_account" {
  metadata {
    name      = var.service_account_name
    namespace = var.namespace
  }
}

resource "kubernetes_validating_webhook_configuration_v1" "lacework_admission_controller_webhook" {
  metadata {
    name = var.admission_controller_name
  }
  webhook {
    name                      = "validate.lacework.net"
    failure_policy            = var.failure_policy
    side_effects              = "None"
    admission_review_versions = ["v1beta1"]
    timeout_seconds           = var.webhook_timeout
    namespace_selector {
      match_expressions {
        key      = "admission-webhook"
        operator = "NotIn"
        values   = ["false"]
      }
    }
    client_config {
      ca_bundle = var.use_self_signed_certs ? tls_self_signed_cert.ca[0].cert_pem : var.ca_cert
      service {
        name      = var.admission_controller_name
        namespace = var.namespace
        path      = "/validate"
      }
    }
    rule {
      api_groups   = ["apps", ""]
      api_versions = ["*"]
      operations   = ["CREATE", "CONNECT"]
      resources    = ["pods", "deployments", "pods/exec"]
    }
  }
}

resource "kubernetes_deployment" "lacework_proxy_scanner" {
  count = var.deploy_combined ? 1 : 0
  metadata {
    name      = var.proxy_scanner_name
    namespace = var.namespace
  }
  spec {
    revision_history_limit = var.revision_history_limit
    replicas               = 1

    selector {
      match_labels = {
        name = "lacework"
      }
    }
    template {
      metadata {
        labels = {
          name = "lacework"
          app  = var.proxy_scanner_name
        }
      }

      spec {
        dynamic "toleration" {
          for_each = var.tolerations
          content {
            key      = lookup(toleration.value, "key", "")
            operator = lookup(toleration.value, "operator", "Equal")
            value    = lookup(toleration.value, "operator", "Equal") == "Exists" ? "" : lookup(toleration.value, "value", "")
            effect   = lookup(toleration.value, "effect", "")
          }
        }

        service_account_name = var.service_account_name

        container {
          name              = var.proxy_scanner_name
          image             = join(":", [var.proxy_scanner_image, var.proxy_scanner_image_tag])
          image_pull_policy = var.image_pull_policy
          port {
            container_port = 8080
          }
          liveness_probe {
            tcp_socket {
              port = 8080
            }
          }
          volume_mount {
            name       = "certs"
            mount_path = "/certs"
            read_only  = false
          }
          volume_mount {
            name       = "scanner-config-volume"
            mount_path = "/opt/lacework/config"
            read_only  = false
          }
          env {
            name  = "LOG_LEVEL"
            value = var.proxy_scanner_log_level
          }
        }
        volume {
          name = "certs"
          secret {
            secret_name = var.certs_secret_name
          }
        }
        volume {
          name = "scanner-config-volume"
          secret {
            secret_name = var.proxy_scanner_name
          }
        }
      }
    }
  }
}

resource "kubernetes_secret" "lacework_proxy_scanner_config" {
  count = var.deploy_combined ? 1 : 0
  metadata {
    name      = var.proxy_scanner_name
    namespace = var.namespace
  }
  data = local.ps_config
}

resource "kubernetes_service" "lacework_proxy_scanner_service" {
  count = var.deploy_combined ? 1 : 0
  metadata {
    name      = var.proxy_scanner_name
    namespace = var.namespace
    labels = {
      role = var.admission_controller_name
    }
  }
  spec {
    port {
      port        = 8080
      target_port = 8080
    }
    selector = {
      app = var.proxy_scanner_name
    }
  }
}
