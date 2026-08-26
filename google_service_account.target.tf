resource "google_service_account" "target" {
  account_id   = var.service_account_id
  display_name = "Service account owned by terraform-gcp-iam-authoritative"
}
