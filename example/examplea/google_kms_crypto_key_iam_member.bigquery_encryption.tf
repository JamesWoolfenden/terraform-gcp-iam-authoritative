resource "google_kms_crypto_key_iam_member" "bigquery_encryption" {
  crypto_key_id = google_kms_crypto_key.pubsub.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${data.google_bigquery_default_service_account.this.email}"
}
