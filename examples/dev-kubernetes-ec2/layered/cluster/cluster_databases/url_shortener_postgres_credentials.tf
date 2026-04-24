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

resource "kubernetes_config_map_v1" "url_shortener_postgres_init" {
  metadata {
    name      = "url-shortener-postgres-init"
    namespace = "databases"
  }
  data = {
    "init.sql" = file("${path.module}/sql/url_shortener_init.sql")
  }
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
        volume {
          name = "postgres-init-sql"
          config_map {
            name = kubernetes_config_map_v1.url_shortener_postgres_init.metadata[0].name
          }
        }
        container {
          name  = "apply-url-shortener-postgres-user"
          image = "postgres:17-alpine"
          volume_mount {
            name       = "postgres-init-sql"
            mount_path = "/sql"
          }
          command = ["/bin/sh", "-c"]
          args = [<<-SCRIPT
    set -e
    export PGPASSWORD="$POSTGRES_PASSWORD"
    HOST=postgres-service.databases.svc.cluster.local
    psql \
    -h $HOST \
    -U "$POSTGRES_USER" \
    --variable=user="$URL_SHORTENER_POSTGRES_USER" \
    --variable=password="$URL_SHORTENER_POSTGRES_PASSWORD" \
    -f /sql/init.sql
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
        }
      }
    }
  }
}
