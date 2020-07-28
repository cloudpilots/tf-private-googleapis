resource "google_project_service" "dns" {
  project                    = var.project_id
  service                    = "dns.googleapis.com"
  disable_dependent_services = false
}
