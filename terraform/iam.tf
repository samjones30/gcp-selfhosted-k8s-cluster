resource "google_service_account" "k8s_service_account" {
  account_id   = var.project_name
  display_name = "${var.project_name}-service-account"
  project      = var.project_id
}