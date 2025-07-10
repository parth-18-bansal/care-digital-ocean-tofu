# provider
variable "do_token" {}

# database
variable "database_name" {
  description = "value"
  type = string
}

variable "database_engine" {
    description = "value"
    type = string
}

variable "database_size" {
    description = "value"
    type = string
}

variable "database_region" {
    description = "value"
    type = string
}

variable "database_node_count" {
    description = "value"
    type = string
}

variable "database_cluster_version" {
    description = ""
    type = string
}

# spaces
variable "care_bucket_name" {
    description = "value"
    type = string
}

variable "care_bucket_region" {
    description = "value"
    type = string
}