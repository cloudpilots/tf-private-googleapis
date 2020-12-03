variable "project_id" {
  description = "GCP Project ID"
}

variable "network_url" {
  description = "GCP network id to attach cloud DNS zones"
  default     = null
}

variable "network_urls" {
  description = "GCP network ids to attach cloud DNS zones"
  type        = list(string)
  default     = []
}

variable "restricted_access" {
  description = "Use only restricted access"
  default     = false
  type        = bool
}
