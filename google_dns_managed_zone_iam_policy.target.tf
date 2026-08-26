resource "google_dns_managed_zone_iam_policy" "target" {
  managed_zone = google_dns_managed_zone.target.name
  policy_data  = data.google_iam_policy.zone.policy_data
}
