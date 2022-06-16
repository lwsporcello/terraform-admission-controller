locals {
  ac_config = {
    "admission.yaml" = yamlencode({
      logger : {
        debug : var.enable_debug_logging
      },
      admission : {
        tls_port : var.tls_port
        cert_file_path : var.cert_file_path
        cert_key_path : var.cert_key_path
        excluded_resources : var.excluded_resources
      },
      policy : {
        block_exec : var.block_exec
        bypass_scope : var.bypass_scope
      },
      scanner : {
        server : var.proxy_scanner_name
        namespace : var.namespace
        timeout : var.admission_scanner_timeout
        skipVerify : var.skip_verify
        caCert : var.use_self_signed_certs ? tls_self_signed_cert.ca[0].cert_pem : file(var.ca_cert)
        defaultRegistry : var.default_registry
        blockOnError : var.block_on_error
      }
      proxy-scanner : {
        certs : {
          skipCert : var.skip_cert
          serverCertificate : var.skip_cert ? null : (var.use_self_signed_certs ? tls_locally_signed_cert.admission[0].cert_pem : file(var.ca_cert))
          serverKey : var.skip_cert ? null : (var.use_self_signed_certs ? tls_private_key.admission[0].private_key_pem : file(var.ca_cert))
        }
      }
    })
  }
  ps_config = {
    "config.yml" = yamlencode({
      static_cache_location : var.static_cache_location
      scan_public_registries : var.scan_public_registries
      lacework : {
        account_name : var.lacework_account_name
        integration_access_token : var.proxy_scanner_token
      },
      registries : var.registries
    }),
    "docker_apis.yml" = yamlencode({
      v2_registry : {
        list_repositories : {
          method : "GET"
          api : "/v2/_catalog"
          token_scope : "registry:catalog:*"
          json_path : "$.repositories[*]"
        },
        list_tags : {
          method : "GET"
          api : "/v2/%repository/tags/list"
          token_scope : "repository:%repository:pull"
          json_path : "$.tags[*]"
        },
        manifest : {
          method : "GET"
          api : "/v2/%repository/manifests/%reference"
          token_scope : "repository:%repository:pull"
        },
        blob : {
          method : "GET"
          api : "/v2/%repository/blobs/%digest"
          token_scope : "repository:%repository:pull"
        }
      }
    }),
    "notifications.yml" = yamlencode({
      dtr : {
        digest : "$.contents.digest"
        tag : "$.contents.tag"
        org : "$.contents.namespace"
        repo : "$.contents.repository"
      },
      v2_registry : {
        digest : "$.events[0].target.digest"
        tag : "$.events[0].target.tag"
        repo : "$.events[0].target.repository"
      },
      jfrog : {
        digest : "$.data.sha256"
        tag : "$.data.tag"
        org : "$.data.repo_key"
        repo : "$.data.path"
      },
      acr : {
        digest : "$.target.digest"
        tag : "$.target.tag"
        repo : "$.target.repository"
      },
      hub : {
        tag : "$.push_data.tag"
        repo : "$.repository.repo_name"
      },
      ghcr : {
        digest : "$.package.package_version.container_metadata.tag.digest"
        tag : "$.package.package_version.container_metadata.tag.name"
        org : "$.package.namespace"
        repo : "$.package.name"
      }
    })
  }
}
