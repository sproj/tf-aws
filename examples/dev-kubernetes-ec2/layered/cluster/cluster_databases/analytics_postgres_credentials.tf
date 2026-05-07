resource "random_password" "analytics_postgres_password" {
  length           = 32
  special          = true
  override_special = "!#$&*()-_=+[]{}<>:?"
}

resource "aws_ssm_parameter" "analytics_postgres_user" {
  name      = "/${var.env}/${var.name_prefix}/analytics/postgres-user"
  type      = "SecureString"
  value     = "analytics"
  overwrite = true
}

resource "aws_ssm_parameter" "analytics_postgres_password" {
  name      = "/${var.env}/${var.name_prefix}/analytics/postgres-password"
  type      = "SecureString"
  value     = random_password.analytics_postgres_password.result
  overwrite = true
}

resource "aws_ssm_parameter" "analytics_postgres_db" {
  name      = "/${var.env}/${var.name_prefix}/analytics/POSTGRES_DB"
  type      = "String"
  value     = "analytics"
  overwrite = true
}

resource "kubernetes_config_map_v1" "analytics_postgres_init" {
  metadata {
    name      = "analytics-postgres-init"
    namespace = "databases"
  }
  data = {
    "init.sql" = file("${path.module}/sql/analytics_init.sql")
  }
}

resource "kubernetes_job" "apply_analytics_postgres_user" {
  depends_on = [kubernetes_manifest.postgres_external_secrets, kubernetes_manifest.postgres_stateful_set, kubernetes_manifest.postgres_service]
  metadata {
    name      = "apply-analytics-postgres-user"
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
            name = kubernetes_config_map_v1.analytics_postgres_init.metadata[0].name
          }
        }
        container {
          name  = "apply-analytics-postgres-user"
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
    until pg_isready -h $HOST -U "$POSTGRES_USER"; do
      echo "Waiting for postgres..."
      sleep 3
    done
    psql \
    -h $HOST \
    -U "$POSTGRES_USER" \
    --variable=user="$ANALYTICS_POSTGRES_USER" \
    --variable=password="$ANALYTICS_POSTGRES_PASSWORD" \
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
            name = "ANALYTICS_POSTGRES_USER"
            value_from {
              secret_key_ref {
                name = "databases-secrets"
                key  = "ANALYTICS_POSTGRES_USER"
              }
            }
          }
          env {
            name = "ANALYTICS_POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = "databases-secrets"
                key  = "ANALYTICS_POSTGRES_PASSWORD"
              }
            }
          }
        }
      }
    }
  }
}
