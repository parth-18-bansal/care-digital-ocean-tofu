module "spaces" {
    source        = "terraform-do-modules/spaces/digitalocean"
    version       = "1.0.0"
    name          = var.care_bucket_name
    environment   = "dev"
    acl           = "private"
    force_destroy = false
    region        = var.care_bucket_region
}

resource "digitalocean_spaces_bucket_cors_configuration" "test" {
  bucket = module.spaces.name
  region = var.care_bucket_region

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST", "PUT", "DELETE"]
    allowed_origins = ["https://${digitalocean_app.frontend_app.live_domain}"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3600
  }
}
