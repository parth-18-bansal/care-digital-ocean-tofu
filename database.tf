module "postgresql" {
    source                       = "terraform-do-modules/database/digitalocean"
    version                      = "1.0.0"
    name                         = var.database_name
    environment                  = "dev"
    region                       = var.database_region
    cluster_engine               = var.database_engine
    cluster_version              = var.database_cluster_version
    cluster_size                 = var.database_size
    cluster_node_count           = var.database_node_count
    create_pools                 = false
    # firewall_rules = [
    #   {
    #     type = "app"
    #     value = digitalocean_app.backend_app.id
    #   }
    # ]

    # depends_on = [ digitalocean_app.backend_app ]
}

resource "digitalocean_database_firewall" "firewall" {
  cluster_id = module.postgresql.database_cluster_id[0]
  rule {
    type = "app"
    value = digitalocean_app.backend_app.id
  }
  depends_on = [module.postgresql, digitalocean_app.backend_app]
}