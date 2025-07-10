module "spaces" {
    source        = "terraform-do-modules/spaces/digitalocean"
    version       = "1.0.0"
    name          = var.care_bucket_name
    environment   = "dev"
    acl           = "private"
    force_destroy = false
    region        = var.care_bucket_region
}