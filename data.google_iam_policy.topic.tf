data "google_iam_policy" "topic" {
  binding {
    role    = "roles/pubsub.publisher"
    members = var.topic_publishers
  }

  binding {
    role    = "roles/pubsub.subscriber"
    members = var.topic_subscribers
  }
}
