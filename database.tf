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
  }