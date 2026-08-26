data "google_iam_policy" "service_account" {
  binding {
    role    = "roles/iam.serviceAccountUser"
    members = var.service_account_users
  }
}
