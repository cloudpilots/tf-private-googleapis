# tf-private-googleapis

Terraform module to configure Cloud DNS for private google api access

Usage

```hcl
module "google-private-access" {
  source      = "github.com/cloudpilots/tf-private-googleapis"
  project_id  = "project-123"
  network_urls = [
    "projects/project-123/global/networks/default"
  ]
}

```
