# This replaces the ENTIRE IAM policy of the project, including the grants Google
# service agents hold on it. Off unless var.project_bindings is non-empty, and the
# variable's validation refuses primitive roles and public principals. Read the
# README section on this resource before setting it.
resource "google_project_iam_policy" "project" {
  count = length(var.project_bindings) == 0 ? 0 : 1

  project     = var.project
  policy_data = data.google_iam_policy.project[0].policy_data
}
