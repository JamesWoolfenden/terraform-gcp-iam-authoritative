resource "google_kms_key_ring" "pubsub" {
  name     = "pubsub-keyring"
  location = "europe-west2"
}
