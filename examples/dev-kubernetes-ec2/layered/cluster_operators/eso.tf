# Install ESO
resource "kubernetes_namespace" "external_secrets_namespace" {
  metadata {
    name = "external-secrets"
  }
}

data "aws_ssm_parameter" "eso_reader_ssm_access_key_id" {
  name            = "/${var.env}/${var.name_prefix}/eso-reader-ssm-access-key-id"
  with_decryption = true
}

data "aws_ssm_parameter" "eso_reader_ssm_secret_access_key" {
  name            = "/${var.env}/${var.name_prefix}/eso-reader-ssm-secret-access-key"
  with_decryption = true
}

resource "kubernetes_secret" "eso_reader_aws_credentials" {
  data = {
    "access-key-id" : data.aws_ssm_parameter.eso_reader_ssm_access_key_id.value
    "secret-access-key" : data.aws_ssm_parameter.eso_reader_ssm_secret_access_key.value
  }

  metadata {
    namespace = "external-secrets"
    name      = "eso-reader-aws-credentials"
  }
}

resource "helm_release" "external_secrets" {
  namespace  = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  name       = "external-secrets"
  depends_on = [kubernetes_namespace.external_secrets_namespace, kubernetes_secret.eso_reader_aws_credentials]
}