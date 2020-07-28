variable "project_id" {
  description = "GCP Project ID"
}

variable "network_url" {
  description = "GCP network id to attach cloud DNS zones"
}

variable "restricted_access" {
  description = "Use only restricted access"
  default     = false
  type        = bool
}
