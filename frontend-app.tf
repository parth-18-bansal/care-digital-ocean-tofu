resource "digitalocean_app" "frontend_app" {
  spec {
    name   = var.care_frontend_app_name
    region = var.care_frontend_app_region

    dynamic "env" {
        for_each = local.frontend_env_vars
        content {
          key   = env.value.key
          value = env.value.value
          type  = env.value.type
        }
    }

    static_site {
      name               = var.care_frontend_app_component_name

      build_command = "NODE_OPTIONS=\"--max-old-space-size=4096\" npm run build"

      github {
        branch         = var.care_frontend_app_github_branch
        deploy_on_push = true
        repo           = var.care_frontend_app_github_repo
      }
    } 
  }
}
