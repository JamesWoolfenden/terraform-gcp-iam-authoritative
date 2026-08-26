resource "google_bigquery_dataset" "target" {
  dataset_id                      = var.dataset_id
  location                        = var.location
  description                     = "Dataset owned by terraform-gcp-iam-authoritative"
  delete_contents_on_destroy      = false
  default_table_expiration_ms     = var.default_table_expiration_ms
  default_partition_expiration_ms = var.default_table_expiration_ms

  default_encryption_configuration {
    kms_key_name = var.kms_key_name
  }
}
