resource "google_dns_record_set" "caa" {
  name         = google_dns_managed_zone.target.dns_name
  managed_zone = google_dns_managed_zone.target.name
  type         = "CAA"
  ttl          = 3600
  rrdatas      = var.caa_records
}
