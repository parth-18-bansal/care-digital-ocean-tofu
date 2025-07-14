# provider
do_token = ""
spaces_access_key = ""
spaces_secret_key = ""

# database
database_name = "demo-db"
database_engine = "pg"
database_region = "blr1"
database_size = "db-s-1vcpu-1gb"
database_node_count = 1
database_cluster_version = "16"

# bucket
care_bucket_name = "demo-bucket"
care_bucket_region = "blr1"
care_bucket_key_name = "demo-bucket-key"

# backend app
backend_app_name = "care-backend"
backend_app_region = "blr1"


# backend redis
backend_redis_tag = "6.2.6-v10"
backend_redis_name = "redis"
backend_redis_instance_size = "apps-s-1vcpu-1gb-fixed"
backend_redis_internal_ports = [6379]

#backend django
backend_django_name = "care-django"
backend_django_instance_size = "apps-s-1vcpu-1gb-fixed"
backend_django_http_port = 9000

# backend celery worker
backend_celery_worker_name = "care-celery-worker"
backend_celery_worker_instance_size = "apps-s-1vcpu-1gb-fixed"

#backend celery beat
backend_celery_beat_name = "care-celery-beat"
backend_celery_beat_instance_size = "apps-s-1vcpu-1gb-fixed"

# care frontend
care_frontend_app_name = "care-frontend"
care_frontend_app_component_name = "care-frontend"
care_frontend_app_region = "blr1"
care_frontend_app_github_branch = "develop"
care_frontend_app_github_repo = "parth-18-bansal/care_fe"

