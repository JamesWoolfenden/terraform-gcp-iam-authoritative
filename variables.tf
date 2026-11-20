# holden:ignore:HLD_TF_027 — this module deliberately covers four different resources,
# because each authoritative *_iam_policy resource must also create the resource it owns.
# Splitting it per service would mean four modules that each exist only to demonstrate the
# same hazard.
variable "service_account_id" {
  type        = string
  description = "Account ID of the service account whose IAM policy this module owns"

  validation {
    condition     = can(regex("^[a-z][-a-z0-9]{4,28}[a-z0-9]$", var.service_account_id))
    error_message = "var.service_account_id must be 6-30 lowercase characters, starting with a letter"
  }
}

variable "service_account_users" {
  type        = list(string)
  description = "The complete list of principals with roles/iam.serviceAccountUser on the service account. Anything not listed loses access"

  validation {
    condition     = length(var.service_account_users) > 0
    error_message = "var.service_account_users must contain at least one principal, an empty policy locks everyone out"
  }

  validation {
    condition     = !anytrue([for m in var.service_account_users : contains(["allUsers", "allAuthenticatedUsers"], m)])
    error_message = "var.service_account_users must not contain allUsers or allAuthenticatedUsers"
  }
}

variable "topic_name" {
  type        = string
  description = "Name of the Pub/Sub topic whose IAM policy this module owns"

  validation {
    condition     = can(regex("^[a-zA-Z][-a-zA-Z0-9_.~+%]{2,254}$", var.topic_name))
    error_message = "var.topic_name must be a valid Pub/Sub topic name"
  }
}

variable "topic_publishers" {
  type        = list(string)
  description = "The complete list of principals with roles/pubsub.publisher on the topic"

  validation {
    condition     = length(var.topic_publishers) > 0
    error_message = "var.topic_publishers must contain at least one principal"
  }

  validation {
    condition     = !anytrue([for m in var.topic_publishers : contains(["allUsers", "allAuthenticatedUsers"], m)])
    error_message = "var.topic_publishers must not contain allUsers or allAuthenticatedUsers"
  }
}

variable "topic_subscribers" {
  type        = list(string)
  description = "The complete list of principals with roles/pubsub.subscriber on the topic"

  validation {
    condition     = length(var.topic_subscribers) > 0
    error_message = "var.topic_subscribers must contain at least one principal"
  }

  validation {
    condition     = !anytrue([for m in var.topic_subscribers : contains(["allUsers", "allAuthenticatedUsers"], m)])
    error_message = "var.topic_subscribers must not contain allUsers or allAuthenticatedUsers"
  }
}

variable "zone_name" {
  type        = string
  description = "Name of the Cloud DNS managed zone whose IAM policy this module owns"

  validation {
    condition     = can(regex("^[a-z][-a-z0-9]{0,62}$", var.zone_name))
    error_message = "var.zone_name must be lowercase and start with a letter"
  }
}

variable "dns_name" {
  type        = string
  description = "DNS name of the managed zone, with a trailing dot"

  validation {
    condition     = can(regex("[.]$", var.dns_name))
    error_message = "var.dns_name must end with a dot, for example example.com."
  }
}

variable "zone_readers" {
  type        = list(string)
  description = "The complete list of principals with roles/dns.reader on the managed zone"

  validation {
    condition     = length(var.zone_readers) > 0
    error_message = "var.zone_readers must contain at least one principal"
  }

  validation {
    condition     = !anytrue([for m in var.zone_readers : contains(["allUsers", "allAuthenticatedUsers"], m)])
    error_message = "var.zone_readers must not contain allUsers or allAuthenticatedUsers"
  }
}

variable "dataset_id" {
  type        = string
  description = "ID of the BigQuery dataset whose access entries this module owns"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_]{1,255}$", var.dataset_id))
    error_message = "var.dataset_id must be letters, digits or underscores"
  }
}

variable "dataset_viewer_groups" {
  type        = list(string)
  description = "Email addresses of the groups granted roles/bigquery.dataViewer on the dataset"
  default     = []

  validation {
    condition     = alltrue([for g in var.dataset_viewer_groups : can(regex("^[^@]+@[^@]+[.][^@]+$", g))])
    error_message = "var.dataset_viewer_groups entries must be bare email addresses, without a group: prefix"
  }
}

variable "location" {
  type        = string
  description = "Location of the BigQuery dataset"
  default     = "europe-west2"

  validation {
    condition     = length(trimspace(var.location)) > 0
    error_message = "var.location must be a non-empty string"
  }
}

variable "kms_key_name" {
  type        = string
  description = "Resource name of the Cloud KMS key used by the topic and dataset (CMEK)"
  sensitive   = true

  validation {
    condition     = length(trimspace(var.kms_key_name)) > 0
    error_message = "var.kms_key_name must be a non-empty string"
  }
}

variable "allowed_persistence_regions" {
  type        = list(string)
  description = "Regions Pub/Sub may persist messages in"
  default     = ["europe-west2"]

  validation {
    condition     = length(var.allowed_persistence_regions) > 0
    error_message = "var.allowed_persistence_regions must contain at least one region"
  }
}

variable "message_retention_duration" {
  type        = string
  description = "How long Pub/Sub retains published messages on the topic, in seconds with an s suffix"
  default     = "604800s"

  validation {
    condition     = can(regex("^[0-9]+s$", var.message_retention_duration))
    error_message = "var.message_retention_duration must be a duration in seconds, e.g. 604800s"
  }
}

variable "default_table_expiration_ms" {
  type        = number
  description = "Default lifetime of tables created in the dataset, in milliseconds. Tables are deleted when it expires. null (the default) keeps tables indefinitely"
  default     = null

  validation {
    condition     = var.default_table_expiration_ms == null ? true : var.default_table_expiration_ms >= 3600000
    error_message = "var.default_table_expiration_ms must be null or at least 3600000 (one hour)"
  }
}

variable "default_partition_expiration_ms" {
  type        = number
  description = "Default lifetime of each partition in partitioned tables in the dataset, in milliseconds. Old partitions are deleted, the table is kept. null (the default) keeps partitions indefinitely"
  default     = null

  validation {
    condition     = var.default_partition_expiration_ms == null ? true : var.default_partition_expiration_ms >= 3600000
    error_message = "var.default_partition_expiration_ms must be null or at least 3600000 (one hour)"
  }
}

variable "caa_records" {
  type        = list(string)
  description = "CAA records restricting which certificate authorities may issue for the zone"
  default     = ["0 issue \"pki.goog\""]

  validation {
    condition     = length(var.caa_records) > 0
    error_message = "var.caa_records must contain at least one record, an empty CAA set permits any CA"
  }
}

variable "project" {
  type        = string
  description = "Project whose entire IAM policy is replaced when var.project_bindings is set"
  default     = ""

  validation {
    condition     = var.project == "" || can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project))
    error_message = "var.project must be a project ID"
  }
}

variable "project_bindings" {
  type = list(object({
    role    = string
    members = list(string)
  }))
  description = "The COMPLETE project IAM policy. Every binding the project should have, including those Google service agents need. Empty (the default) leaves the project policy alone"
  default     = []

  validation {
    condition     = !anytrue([for b in var.project_bindings : contains(["roles/owner", "roles/editor", "roles/viewer"], b.role)])
    error_message = "var.project_bindings must not use the primitive roles owner, editor or viewer"
  }

  validation {
    condition     = !anytrue([for b in var.project_bindings : anytrue([for m in b.members : contains(["allUsers", "allAuthenticatedUsers"], m)])])
    error_message = "var.project_bindings must not contain allUsers or allAuthenticatedUsers"
  }

  validation {
    condition     = length(var.project_bindings) == 0 || anytrue([for b in var.project_bindings : b.role == "roles/resourcemanager.projectIamAdmin" && length(b.members) > 0])
    error_message = "var.project_bindings must include a roles/resourcemanager.projectIamAdmin binding with at least one member, otherwise the apply locks everyone out of changing the policy again"
  }
}

variable "project_audit_configs" {
  type = list(object({
    service   = string
    log_types = list(string)
  }))
  description = "Audit log configs written with the project IAM policy when var.project_bindings is set. google_project_iam_policy replaces the project's audit configs too, so anything not listed here is removed"
  default     = []

  validation {
    condition     = alltrue([for c in var.project_audit_configs : length(c.log_types) > 0 && alltrue([for t in c.log_types : contains(["ADMIN_READ", "DATA_READ", "DATA_WRITE"], t)])])
    error_message = "var.project_audit_configs log_types must be non-empty and each one of ADMIN_READ, DATA_READ or DATA_WRITE"
  }
}
