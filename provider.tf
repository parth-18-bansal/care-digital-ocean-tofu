# defining which provider and api to use. By this opentofu knows that it have to talk to the digital ocean cloud api
terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# this is the token used in the api call made by the opentofu to the digital ocean, for authentication, by this opentofu get access to
# the account in the digital ocean.
provider "digitalocean" {
  token = var.do_token

  spaces_access_id  = var.spaces_access_key
  spaces_secret_key = var.spaces_secret_key
}