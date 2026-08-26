resource "google_pubsub_topic_iam_policy" "target" {
  topic       = google_pubsub_topic.target.name
  policy_data = data.google_iam_policy.topic.policy_data
}
