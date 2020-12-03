# https://cloud.google.com/vpc/docs/configure-private-google-access


locals {
  additional_zones = [
    "googleadapis.com",
    "ltsapis.goog",
    "gcr.io",
    "gstatic.com",
    "appspot.com",
    "cloudfunctions.net",
    "pki.goog",
    "cloudproxy.app",
    "run.app",
    "datafusion.googleusercontent.com",
    "datafusion.cloud.google.com",
    "packages.cloud.google.com",
    "gcr.io",
    "appengine.google.com",
    "pki.goog",
  ]
  private_ips = [
    "199.36.153.8",
    "199.36.153.9",
    "199.36.153.10",
    "199.36.153.11",
  ]

  restricted_ips = [
    "199.36.153.4",
    "199.36.153.5",
    "199.36.153.6",
    "199.36.153.7",
  ]

  private = ! var.restricted_access
  cname   = local.private ? "private" : "restricted"
  rrdata  = local.private ? local.private_ips : local.restricted_ips

  network_urls = concat(var.network_urls, var.network_url != null ? [var.network_url] : [])
}

resource "google_dns_managed_zone" "googleapis" {
  name        = "googleapis"
  dns_name    = "googleapis.com."
  description = "Private Googleapi access"
  labels = {
  }

  visibility = "private"

  private_visibility_config {
    dynamic "networks" {
      for_each = toset(local.network_urls)
      content {
        network_url = networks.value
      }
    }
  }

  depends_on = [
    google_project_service.dns
  ]
}

resource "google_dns_record_set" "private" {
  name         = "private.${google_dns_managed_zone.googleapis.dns_name}"
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.googleapis.name
  rrdatas      = local.private_ips
  depends_on = [
    google_dns_managed_zone.googleapis
  ]
}
resource "google_dns_record_set" "restricted" {
  name         = "restricted.${google_dns_managed_zone.googleapis.dns_name}"
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.googleapis.name
  rrdatas      = local.restricted_ips
  depends_on = [
    google_dns_managed_zone.googleapis
  ]

}
resource "google_dns_record_set" "star" {
  name         = "*.${google_dns_managed_zone.googleapis.dns_name}"
  type         = "CNAME"
  ttl          = 300
  managed_zone = google_dns_managed_zone.googleapis.name
  rrdatas = [
    "${local.cname}.googleapis.com.",
  ]
  depends_on = [
    google_dns_managed_zone.googleapis
  ]
}


resource "google_dns_managed_zone" "more_zones" {
  for_each    = toset(local.additional_zones)
  name        = replace(each.value, ".", "-")
  dns_name    = "${each.value}."
  description = "${each.value} private googleapi access"
  labels = {
  }

  visibility = "private"

  private_visibility_config {
    dynamic "networks" {
      for_each = toset(local.network_urls)
      content {
        network_url = networks.value
      }
    }
  }
  depends_on = [
    google_project_service.dns
  ]

}

resource "google_dns_record_set" "more_zones_a" {
  for_each     = toset(local.additional_zones)
  name         = "${each.value}."
  type         = "A"
  ttl          = 300
  managed_zone = replace(each.value, ".", "-")
  rrdatas      = local.rrdata
  depends_on = [
    google_dns_managed_zone.more_zones,
  ]
}

resource "google_dns_record_set" "more_zones_cname" {
  for_each     = toset(local.additional_zones)
  name         = "*.${each.value}."
  type         = "CNAME"
  ttl          = 300
  managed_zone = replace(each.value, ".", "-")
  rrdatas = [
    "${each.value}.",
  ]
  depends_on = [
    google_dns_managed_zone.more_zones,
  ]
}
