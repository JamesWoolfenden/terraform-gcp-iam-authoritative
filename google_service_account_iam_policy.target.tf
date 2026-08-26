resource "google_service_account_iam_policy" "target" {
  service_account_id = google_service_account.target.name
  policy_data        = data.google_iam_policy.service_account.policy_data
}
