# Root CA Key and Certificate
resource "tls_private_key" "root_ca_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "root_ca_cert" {
  private_key_pem = tls_private_key.root_ca_key.private_key_pem

  is_ca_certificate     = true
  validity_period_hours = 36500
  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "key_encipherment",
    "digital_signature",
  ]

  subject {
    common_name  = "Acme CA"
    organization = "Acme Inc."
    country      = "US"
    locality     = "New York"
  }
}

# Server Key and CSR
resource "tls_private_key" "server_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "server_csr" {
  private_key_pem = tls_private_key.server_key.private_key_pem

  subject {
    common_name         = "Acme.com"
    organization        = "Acme"
    organizational_unit = "Innovation"
    country             = "US"
  }
}

# Sign the Server Certificate with the Root CA
resource "tls_locally_signed_cert" "server_cert" {
  cert_request_pem   = tls_cert_request.server_csr.cert_request_pem
  ca_private_key_pem = tls_private_key.root_ca_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.root_ca_cert.cert_pem

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
  ]
}

resource "local_file" "ca_key" {
  content  = tls_private_key.root_ca_key.private_key_pem
  filename = "${path.module}/ca.key"
}

resource "local_file" "ca_cert" {
  content  = tls_self_signed_cert.root_ca_cert.cert_pem
  filename = "${path.module}/ca.cert"
}

resource "local_file" "server_key" {
  content  = tls_private_key.server_key.private_key_pem
  filename = "${path.module}/server.key"
}

resource "local_file" "server_cert" {
  content  = tls_locally_signed_cert.server_cert.cert_pem
  filename = "${path.module}/server.cert"
}
