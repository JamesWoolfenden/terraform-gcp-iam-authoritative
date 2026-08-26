output "service_account_email" {
  value       = google_service_account.target.email
  description = "Email of the service account whose IAM policy this module owns"
}

output "topic_id" {
  value       = google_pubsub_topic.target.id
  description = "ID of the Pub/Sub topic whose IAM policy this module owns"
}

output "managed_zone_id" {
  value       = google_dns_managed_zone.target.id
  description = "ID of the managed zone whose IAM policy this module owns"
}

output "dataset_id" {
  value       = google_bigquery_dataset.target.id
  description = "ID of the BigQuery dataset whose access entries this module owns"
}

output "project_policy_etag" {
  value       = try(google_project_iam_policy.project[0].etag, null)
  description = "Etag of the project IAM policy, null when var.project_bindings is empty"
}
