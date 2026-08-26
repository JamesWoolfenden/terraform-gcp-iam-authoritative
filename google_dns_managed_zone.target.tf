resource "google_dns_managed_zone" "target" {
  name        = var.zone_name
  dns_name    = var.dns_name
  description = "Managed zone owned by terraform-gcp-iam-authoritative"

  dnssec_config {
    state = "on"
  }

  cloud_logging_config {
    enable_logging = true
  }
}
