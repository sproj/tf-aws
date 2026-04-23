resource "random_password" "url_shortener_postgres_password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_ssm_parameter" "url_shortener_postgres_user" {
  name      = "/${var.env}/${var.name_prefix}/url-shortener/postgres-user"
  type      = "SecureString"
  value     = "url_shortener"
  overwrite = true
}

resource "aws_ssm_parameter" "url_shortener_postgres_password" {
  name      = "/${var.env}/${var.name_prefix}/url-shortener/postgres-password"
  type      = "SecureString"
  value     = random_password.url_shortener_postgres_password.result
  overwrite = true
}

resource "aws_ssm_parameter" "url_shortener_postgres_db" {
  name      = "/${var.env}/${var.name_prefix}/url-shortener/POSTGRES_DB"
  type      = "String"
  value     = "url_shortener"
  overwrite = true
}

resource "kubernetes_job" "apply_url_shortener_postgres_user" {
  depends_on = [kubernetes_manifest.postgres_external_secrets, kubernetes_manifest.postgres_stateful_set, kubernetes_manifest.postgres_service]
  metadata {
    name      = "apply-url-shortener-postgres-user"
    namespace = "databases"
  }
  spec {
    template {
      metadata {
        labels = {
          "component" : "postgres"
        }
      }
      spec {
        restart_policy = "Never"
        container {
          name    = "apply-url-shortener-postgres-user"
          image   = "postgres:17-alpine"
          command = ["/bin/sh", "-c"]
          args = [<<-SCRIPT
    set -e
    export PGPASSWORD="$POSTGRES_PASSWORD"
    HOST=postgres-service.databases.svc.cluster.local
    psql -h "$HOST" -U "$POSTGRES_USER" -tc "SELECT 1 FROM pg_roles WHERE rolname='$URL_SHORTENER_POSTGRES_USER'" \
      | grep -q 1 \
      || psql -h "$HOST" -U "$POSTGRES_USER" -c "CREATE USER $URL_SHORTENER_POSTGRES_USER WITH PASSWORD '$URL_SHORTENER_POSTGRES_PASSWORD'"
    psql -h "$HOST" -U "$POSTGRES_USER" -tc "SELECT 1 FROM pg_database WHERE datname='$URL_SHORTENER_POSTGRES_DB'" \
      | grep -q 1 \
      || psql -h "$HOST" -U "$POSTGRES_USER" -c "CREATE DATABASE $URL_SHORTENER_POSTGRES_DB OWNER $URL_SHORTENER_POSTGRES_USER"                  
    psql -h "$HOST" -U "$POSTGRES_USER" -c "GRANT ALL PRIVILEGES ON DATABASE $URL_SHORTENER_POSTGRES_DB TO $URL_SHORTENER_POSTGRES_USER"
  SCRIPT
          ]
          env {
            name = "POSTGRES_USER"
            value_from {
              secret_key_ref {
                name = "databases-secrets"
                key  = "POSTGRES_USER"
              }
            }
          }
          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = "databases-secrets"
                key  = "POSTGRES_PASSWORD"
              }
            }
          }
          env {
            name = "URL_SHORTENER_POSTGRES_USER"
            value_from {
              secret_key_ref {
                name = "databases-secrets"
                key  = "URL_SHORTENER_POSTGRES_USER"
              }
            }
          }
          env {
            name = "URL_SHORTENER_POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = "databases-secrets"
                key  = "URL_SHORTENER_POSTGRES_PASSWORD"
              }
            }
          }
          env {
            name = "URL_SHORTENER_POSTGRES_DB"
            value_from {
              secret_key_ref {
                name = "databases-secrets"
                key  = "URL_SHORTENER_POSTGRES_DB"
              }
            }
          }
        }
      }
    }
  }
}
