data "google_iam_policy" "project" {
  count = length(var.project_bindings) == 0 ? 0 : 1

  dynamic "binding" {
    for_each = var.project_bindings

    content {
      role    = binding.value.role
      members = binding.value.members
    }
  }
}
