resource "google_bigquery_dataset_access" "viewer" {
  for_each = toset(var.dataset_viewer_groups)

  dataset_id     = google_bigquery_dataset.target.dataset_id
  role           = "roles/bigquery.dataViewer"
  group_by_email = each.value
}
