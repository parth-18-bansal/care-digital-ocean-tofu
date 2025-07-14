# provider
variable "do_token" {
    type = string
    description = "DigitalOcean API token"
    sensitive   = true
}

variable "spaces_access_key" {
    description = "value"
    type = string
}

variable "spaces_secret_key" {
    description = "value"
    type = string
}

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

variable "care_bucket_key_name" {
    description = "value"
    type = string
}

# backend app
variable "backend_app_name" {
    description = "value"
    type = string
}

variable "backend_app_region" {
    description = "value"
    type = string
}


# backend redis
variable "backend_redis_tag" {
    description = "value"
    type = string 
}

variable "backend_redis_name" {
    description = "Name of the redis component"
    type = string
}

variable "backend_redis_instance_size" {
    description = "size of the instance for the redis"
    type = string
}

variable "backend_redis_internal_ports" {
    description = "list of internal ports"
    type = list(number)
  
}

# backend django
variable "backend_django_name" {
    description = "Name of the django component"
    type = string 
}

variable "backend_django_instance_size" {
    description = "size of the instance for the django"
    type = string
}

variable "backend_django_http_port" {
    description = "port of the django component"
    type = string
}

# backend celery worker
variable "backend_celery_worker_name" {
    description = "Name of the celery worker component"
    type = string 
}

variable "backend_celery_worker_instance_size" {
    description = "size of the instance for the celery worker"
    type = string
}

# backend celery beat
variable "backend_celery_beat_name" {
    description = "Name of the celery beat component"
    type = string 
}

variable "backend_celery_beat_instance_size" {
    description = "size of the instance for the celery beat"
    type = string
}


# care frontend
variable "care_frontend_app_name" {
    description = "Name of the frontend app"
    type = string
}

variable "care_frontend_app_component_name" {
    description = "Name of the frontend app's component"
    type = string
}

variable "care_frontend_app_region" {
    description = "Region of the frontend app"
    type = string
}

variable "care_frontend_app_github_branch" {
    description = "Github branch of the source code"
    type = string
}

variable "care_frontend_app_github_repo" {
    description = "Github repo for the source code"
    type = string 
}