locals {
  frontend_env_vars = [
    {
        key   = "REACT_CARE_API_URL"
        value = "https://${digitalocean_app.backend_app.live_domain}"
        type  = "GENERAL"
    },
  ]
}
