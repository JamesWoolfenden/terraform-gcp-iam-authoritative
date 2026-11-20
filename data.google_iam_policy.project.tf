# Computed locally by the provider, no API call, so it needs no count of its own.
data "google_iam_policy" "project" {
  dynamic "binding" {
    for_each = var.project_bindings

    content {
      role    = binding.value.role
      members = binding.value.members
    }
  }

  # google_project_iam_policy writes auditConfigs as well as bindings, so any
  # audit config not listed here is removed from the project on apply.
  dynamic "audit_config" {
    for_each = var.project_audit_configs

    content {
      service = audit_config.value.service

      dynamic "audit_log_configs" {
        for_each = audit_config.value.log_types

        content {
          log_type = audit_log_configs.value
        }
      }
    }
  }
}
