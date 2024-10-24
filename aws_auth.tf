resource "aws_rolesanywhere_trust_anchor" "test" {
  name    = "trusted_cert_auth"
  enabled = true
  source {
    source_data {
      x509_certificate_data = tls_self_signed_cert.root_ca_cert.cert_pem
    }
    source_type = "CERTIFICATE_BUNDLE"
  }
}

resource "aws_iam_role" "test_role" {
  name                = "certificate_role"
  managed_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession",
          "sts:SetSourceIdentity"
        ]
        Effect = "Allow"
        Principal = {
          Service = "rolesanywhere.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_rolesanywhere_profile" "test" {
  name                = "certificate_profile"
  role_arns           = [aws_iam_role.test_role.arn]
  managed_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  enabled             = true
}

resource "local_file" "command" {
  filename = "command.sh"
  content  = <<EOF
#!/bin/bash
keys=$(./aws_signing_helper credential-process --certificate ./server.cert --private-key ./server.key --trust-anchor-arn ${aws_rolesanywhere_trust_anchor.test.arn} --profile-arn ${aws_rolesanywhere_profile.test.arn} --role-arn ${aws_iam_role.test_role.arn})
export AWS_ACCESS_KEY_ID=$(echo $keys | jq -r '.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo $keys | jq -r '.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo $keys | jq -r '.SessionToken')
EOF
}
