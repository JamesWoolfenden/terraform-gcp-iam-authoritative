data "google_iam_policy" "zone" {
  binding {
    role    = "roles/dns.reader"
    members = var.zone_readers
  }
}
