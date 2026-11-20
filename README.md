# terraform-gcp-iam-authoritative

[![Build Status](https://github.com/JamesWoolfenden/terraform-gcp-iam-authoritative/workflows/Verify/badge.svg?branch=master)](https://github.com/JamesWoolfenden/terraform-gcp-iam-authoritative)
[![Latest Release](https://img.shields.io/github/release/terraform-gcp-iam-authoritative.svg)](https://github.com/JamesWoolfenden/terraform-gcp-iam-authoritative/releases/latest)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/JamesWoolfenden/terraform-gcp-iam-authoritative.svg?label=latest)](https://github.com/JamesWoolfenden/terraform-gcp-iam-authoritative/releases/latest)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D1.5.0-blue.svg)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

Terraform module demonstrating the **authoritative** IAM resources — the ones
that replace a resource's entire policy rather than adding to it:
google_service_account_iam_policy, google_pubsub_topic_iam_policy,
google_dns_managed_zone_iam_policy and google_bigquery_dataset_access.
Exercises holden's policies for all four.

## Read this before using it

Each `*_iam_policy` resource **owns the whole policy** of its target. Anything
granted outside this module — by a person in the console, by another Terraform
configuration, by a Google service that grants itself a role — is deleted on
the next apply, without warning, and the resource keeps that policy until
Terraform is told otherwise.

That is why this module **creates the resources it manages**. Pointing an
`*_iam_policy` at something you did not create is how people accidentally
revoke a service agent's access to its own resource. If you only want to add a
grant, use the `_iam_member` (additive) or `_iam_binding` (authoritative for
one role) resources in the per-service modules instead.

### google_project_iam_policy

This one is in a class of its own: it replaces the IAM policy of an entire
project. Google service agents hold grants on your project that nothing in your
Terraform knows about — the Cloud Build agent, the Compute agent, the Pub/Sub
agent — and every one of them is revoked if it is not in `var.project_bindings`.
Services then fail in ways that look nothing like an IAM problem.

It is disabled unless `var.project_bindings` is non-empty. The variable refuses
primitive roles and public principals, and requires a
`roles/resourcemanager.projectIamAdmin` binding so the policy can still be
changed after the apply. Build the list from `gcloud projects get-iam-policy`
output, not from scratch.

The project policy also carries the project's audit log configuration. Any
Data Access audit config not listed in `var.project_audit_configs` is removed
by the apply, so copy the `auditConfigs` from the same `gcloud` output into it.
`var.project` must be set whenever `var.project_bindings` is.

`google_bigquery_dataset_access` has the same problem in reverse: it is a
single access entry, and it conflicts with `google_bigquery_dataset_iam_*` on
the same dataset. Pick one style per dataset.

## Usage

Add **module.authoritative.tf** to your code:-

```terraform
module "authoritative" {
  source = "jameswoolfenden/iam-authoritative/gcp"
  version = "0.0.1"

  service_account_id    = "authoritative-target"
  service_account_users = ["group:platform@example.com"]

  topic_name        = "authoritative-topic"
  topic_publishers  = ["group:producers@example.com"]
  topic_subscribers = ["group:consumers@example.com"]

  zone_name    = "authoritative-zone"
  dns_name     = "internal.example.com."
  zone_readers = ["group:platform@example.com"]

  dataset_id            = "authoritative_dataset"
  dataset_viewer_groups = ["analysts@example.com"]

  kms_key_name = google_kms_crypto_key.pubsub.id
}
```

Every member list must be non-empty — an empty authoritative policy is not a
safe default, it is a lockout. All of them reject allUsers and
allAuthenticatedUsers.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [google_bigquery_dataset.target](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset) | resource |
| [google_bigquery_dataset_access.viewer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset_access) | resource |
| [google_dns_managed_zone.target](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone) | resource |
| [google_dns_managed_zone_iam_policy.target](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone_iam_policy) | resource |
| [google_dns_record_set.caa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_project_iam_policy.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_policy) | resource |
| [google_pubsub_topic.target](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [google_pubsub_topic_iam_policy.target](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic_iam_policy) | resource |
| [google_service_account.target](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_policy.target](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_policy) | resource |
| [google_iam_policy.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/iam_policy) | data source |
| [google_iam_policy.service_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/iam_policy) | data source |
| [google_iam_policy.topic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/iam_policy) | data source |
| [google_iam_policy.zone](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/iam_policy) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_allowed_persistence_regions"></a> [allowed\_persistence\_regions](#input\_allowed\_persistence\_regions) | Regions Pub/Sub may persist messages in | `list(string)` | <pre>[<br/>  "europe-west2"<br/>]</pre> | no |
| <a name="input_caa_records"></a> [caa\_records](#input\_caa\_records) | CAA records restricting which certificate authorities may issue for the zone | `list(string)` | <pre>[<br/>  "0 issue \"pki.goog\""<br/>]</pre> | no |
| <a name="input_dataset_id"></a> [dataset\_id](#input\_dataset\_id) | ID of the BigQuery dataset whose access entries this module owns | `string` | n/a | yes |
| <a name="input_dataset_viewer_groups"></a> [dataset\_viewer\_groups](#input\_dataset\_viewer\_groups) | Email addresses of the groups granted roles/bigquery.dataViewer on the dataset | `list(string)` | `[]` | no |
| <a name="input_default_partition_expiration_ms"></a> [default\_partition\_expiration\_ms](#input\_default\_partition\_expiration\_ms) | Default lifetime of each partition in partitioned tables in the dataset, in milliseconds. Old partitions are deleted, the table is kept. null (the default) keeps partitions indefinitely | `number` | `null` | no |
| <a name="input_default_table_expiration_ms"></a> [default\_table\_expiration\_ms](#input\_default\_table\_expiration\_ms) | Default lifetime of tables created in the dataset, in milliseconds. Tables are deleted when it expires. null (the default) keeps tables indefinitely | `number` | `null` | no |
| <a name="input_dns_name"></a> [dns\_name](#input\_dns\_name) | DNS name of the managed zone, with a trailing dot | `string` | n/a | yes |
| <a name="input_kms_key_name"></a> [kms\_key\_name](#input\_kms\_key\_name) | Resource name of the Cloud KMS key used by the topic and dataset (CMEK) | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Location of the BigQuery dataset | `string` | `"europe-west2"` | no |
| <a name="input_message_retention_duration"></a> [message\_retention\_duration](#input\_message\_retention\_duration) | How long Pub/Sub retains published messages on the topic, in seconds with an s suffix | `string` | `"604800s"` | no |
| <a name="input_project"></a> [project](#input\_project) | Project whose entire IAM policy is replaced when var.project\_bindings is set | `string` | `""` | no |
| <a name="input_project_audit_configs"></a> [project\_audit\_configs](#input\_project\_audit\_configs) | Audit log configs written with the project IAM policy when var.project\_bindings is set. google\_project\_iam\_policy replaces the project's audit configs too, so anything not listed here is removed | <pre>list(object({<br/>    service   = string<br/>    log_types = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_project_bindings"></a> [project\_bindings](#input\_project\_bindings) | The COMPLETE project IAM policy. Every binding the project should have, including those Google service agents need. Empty (the default) leaves the project policy alone | <pre>list(object({<br/>    role    = string<br/>    members = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_service_account_id"></a> [service\_account\_id](#input\_service\_account\_id) | Account ID of the service account whose IAM policy this module owns | `string` | n/a | yes |
| <a name="input_service_account_users"></a> [service\_account\_users](#input\_service\_account\_users) | The complete list of principals with roles/iam.serviceAccountUser on the service account. Anything not listed loses access | `list(string)` | n/a | yes |
| <a name="input_topic_name"></a> [topic\_name](#input\_topic\_name) | Name of the Pub/Sub topic whose IAM policy this module owns | `string` | n/a | yes |
| <a name="input_topic_publishers"></a> [topic\_publishers](#input\_topic\_publishers) | The complete list of principals with roles/pubsub.publisher on the topic | `list(string)` | n/a | yes |
| <a name="input_topic_subscribers"></a> [topic\_subscribers](#input\_topic\_subscribers) | The complete list of principals with roles/pubsub.subscriber on the topic | `list(string)` | n/a | yes |
| <a name="input_zone_name"></a> [zone\_name](#input\_zone\_name) | Name of the Cloud DNS managed zone whose IAM policy this module owns | `string` | n/a | yes |
| <a name="input_zone_readers"></a> [zone\_readers](#input\_zone\_readers) | The complete list of principals with roles/dns.reader on the managed zone | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_dataset_id"></a> [dataset\_id](#output\_dataset\_id) | ID of the BigQuery dataset whose access entries this module owns |
| <a name="output_managed_zone_id"></a> [managed\_zone\_id](#output\_managed\_zone\_id) | ID of the managed zone whose IAM policy this module owns |
| <a name="output_project_policy_etag"></a> [project\_policy\_etag](#output\_project\_policy\_etag) | Etag of the project IAM policy, null when var.project\_bindings is empty |
| <a name="output_service_account_email"></a> [service\_account\_email](#output\_service\_account\_email) | Email of the service account whose IAM policy this module owns |
| <a name="output_topic_id"></a> [topic\_id](#output\_topic\_id) | ID of the Pub/Sub topic whose IAM policy this module owns |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Help

**Got a question?**

File a GitHub [issue](https://github.com/JamesWoolfenden/terraform-gcp-iam-authoritative/issues).

## Copyrights

Copyright © 2019-2026 [Jim Woolfenden](https://github.com/JamesWoolfenden)

## License

See [LICENSE](LICENSE) for full details.


<!-- BEGINNING OF PRE-COMMIT-PIKE DOCS HOOK -->
The Terraform resource required is:

```golang
# apply role
resource "google_project_iam_custom_role" "terraform_pike" {
  project     = "pike-477416"
  role_id     = "terraform_pike"
  title       = "terraform_pike"
  description = "A user with least privileges"
  permissions = [
    "bigquery.datasets.create",
    "bigquery.datasets.delete",
    "bigquery.datasets.get",
    "bigquery.datasets.update",
    "dns.changes.create",
    "dns.changes.get",
    "dns.changes.list",
    "dns.managedZones.create",
    "dns.managedZones.delete",
    "dns.managedZones.get",
    "dns.managedZones.update",
    "dns.resourceRecordSets.create",
    "dns.resourceRecordSets.delete",
    "dns.resourceRecordSets.get",
    "dns.resourceRecordSets.list",
    "dns.resourceRecordSets.update",
    "iam.serviceAccounts.create",
    "iam.serviceAccounts.delete",
    "iam.serviceAccounts.get",
    "iam.serviceAccounts.getIamPolicy",
    "iam.serviceAccounts.setIamPolicy",
    "iam.serviceAccounts.update",
    "pubsub.topics.create",
    "pubsub.topics.delete",
    "pubsub.topics.get",
    "pubsub.topics.getIamPolicy",
    "pubsub.topics.update",
    "resourcemanager.projects.getIamPolicy",
    "resourcemanager.projects.setIamPolicy"
  ]
}

# plan role
resource "google_project_iam_custom_role" "terraform_pike_plan" {
  project     = "pike-477416"
  role_id     = "terraform_pike_plan"
  title       = "terraform_pike_plan"
  description = "A user with least privileges"
  permissions = [
    "bigquery.datasets.get",
    "dns.changes.get",
    "dns.changes.list",
    "dns.managedZones.get",
    "dns.resourceRecordSets.get",
    "dns.resourceRecordSets.list",
    "iam.serviceAccounts.get",
    "iam.serviceAccounts.getIamPolicy",
    "pubsub.topics.get",
    "pubsub.topics.getIamPolicy",
    "resourcemanager.projects.getIamPolicy"
  ]
}


```
<!-- END OF PRE-COMMIT-PIKE DOCS HOOK -->
