resource "google_kms_crypto_key_iam_member" "pubsub_service_agent" {
  crypto_key_id = google_kms_crypto_key.pubsub.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_project_service_identity.pubsub.email}"
}
