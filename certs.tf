resource "tls_private_key" "ca" {
  count     = var.use_self_signed_certs ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "ca" {
  count                 = var.use_self_signed_certs ? 1 : 0
  private_key_pem       = tls_private_key.ca[0].private_key_pem
  validity_period_hours = 2400000
  is_ca_certificate     = true
  allowed_uses = [
    "cert_signing",
    "key_encipherment",
    "digital_signature",
  ]
  subject {
    common_name = "admission_ca"
  }
}

resource "tls_private_key" "admission" {
  count     = var.use_self_signed_certs ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "admission" {
  count           = var.use_self_signed_certs ? 1 : 0
  private_key_pem = tls_private_key.admission[0].private_key_pem
  dns_names = [
    join(".", [var.admission_controller_name, var.namespace, "svc"]),
    join(".", [var.admission_controller_name, var.namespace, "svc", "cluster", "local"]),
    "admission.lacework-dev.svc",
    "admission.lacework-dev.svc.cluster.local",
  ]
  subject {
    common_name = "lacework-admission-controller.lacework.svc"
  }
}

resource "tls_locally_signed_cert" "admission" {
  count = var.use_self_signed_certs ? 1 : 0
  allowed_uses = [
    "cert_signing",
    "key_encipherment",
    "digital_signature",
    "client_auth",
    "server_auth"
  ]
  ca_cert_pem           = tls_self_signed_cert.ca[0].cert_pem
  ca_private_key_pem    = tls_private_key.ca[0].private_key_pem
  cert_request_pem      = tls_cert_request.admission[0].cert_request_pem
  validity_period_hours = 2400000
}
