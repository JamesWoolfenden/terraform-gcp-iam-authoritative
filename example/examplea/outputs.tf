output "topic_id" {
  value       = module.authoritative.topic_id
  description = "ID of the Pub/Sub topic whose IAM policy the module owns"
}
