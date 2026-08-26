resource "google_pubsub_topic" "target" {
  name                       = var.topic_name
  kms_key_name               = var.kms_key_name
  message_retention_duration = var.message_retention_duration

  message_storage_policy {
    allowed_persistence_regions = var.allowed_persistence_regions
  }
}
