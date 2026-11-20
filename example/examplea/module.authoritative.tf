# holden:ignore:HLD_TF_026 — examples intentionally use ../../ to reference the local module root
# holden:ignore:HLD_TF_065: for expansion
module "authoritative" {
  source = "../../"

  service_account_id    = "authoritative-target"
  service_account_users = ["group:platform@example.com"]

  topic_name        = "authoritative-topic"
  topic_publishers  = ["group:producers@example.com"]
  topic_subscribers = ["group:consumers@example.com"]

  zone_name    = "authoritative-zone"
  dns_name     = "internal.example.com."
  zone_readers = ["group:platform@example.com"]

  dataset_id            = "authoritative_dataset"
  dataset_viewer_groups = ["analysts@example.com"]

  location     = "europe-west2"
  kms_key_name = google_kms_crypto_key.pubsub.id

  depends_on = [
    google_kms_crypto_key_iam_member.pubsub_service_agent,
    google_kms_crypto_key_iam_member.bigquery_encryption,
  ]
}
