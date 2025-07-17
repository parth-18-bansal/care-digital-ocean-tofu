terraform {
  backend "s3" {
    bucket                      = "care-tofu-state"
    key                         = "tfstate/terraform.tfstate"
    region                      = "blr1"
    endpoint                    = "https://blr1.digitaloceanspaces.com"
    skip_credentials_validation = true
    skip_region_validation      = true
    force_path_style            = true
  }
}