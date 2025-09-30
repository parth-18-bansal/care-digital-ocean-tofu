# DigitalOcean

In this guide, we'll walk you through deploying the **Care** on **Digital Ocean** through **Tofu**.

---

## Prerequisites

- A DigitalOcean account ([Sign up here](https://www.digitalocean.com)).
- A fork of the Care backend and frontend repositories.
- A registered domain name (optional but recommended).
- Basic familiarity with DigitalOcean's App Platform and Spaces.

---


## Step 1: Install and Setup the Tofu in your System

### 1.1 Generate a Digital Ocean API Token

- First go to the **API** section in the [DigitalOcean account](https://cloud.digitalocean.com/account/api/tokens).
- Generate a Personal Access Token. This token is used by the provider for authentication to the digital ocean api for your account.
- Export the token to your system's shell:

```bash 
export DIGITALOCEAN_TOKEN="your-actual-token"
```

### 1.2 Create Spaces Access & Secret Keys

- Navigate to Spaces Object Storage in the DigitalOcean dashboard.
- Go to the Access Keys tab and create a key with Full Access.
- Export the access credentials:

```bash
export TF_VAR_spaces_access_key="your-access-key"
export TF_VAR_spaces_secret_key="your-secret-key"
```
These credentials are used by the provider and other resources to interact with Spaces buckets.

### 1.3 Install OpenTofu
Visit the [OpenTofu Installation Guide](https://opentofu.org/docs/intro/install/) and follow the instructions for your OS.

### 1.4 Create a Spaces Bucket for Remote State
Manually create a Spaces bucket named:
```perl
care-tofu-state
```

Then export your access credentials again (required by OpenTofu backend):
```bash
export AWS_ACCESS_KEY_ID="your-spaces-access-key"
export AWS_SECRET_ACCESS_KEY="your-spaces-secret-key"
```

---

## step 2: Provider
This file tell the opentofu to interact with the digital ocean cloud api. And also here we define the credentials for your account. So that open tofu can create resources in your account.

```hcl
terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  spaces_access_id  = var.spaces_access_key
  spaces_secret_key = var.spaces_secret_key
}
```

## step 3: tfstate File
This file defines where the tfstate file will get store for your infrastructure

```hcl
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
```

## step 4: create variable.tf and dev.tfvars files
We define all the variables in the variables.tf file and store the values of these variables in the environments/dev.tfvars file.

## step 5: Postgres Database
- create the database.tf file
- write the terraform script in it like this:

```hcl
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
}
```

- Then in variables.tf define the variables

```hcl
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
```

- then in dev.tfvars define the values of them

```hcl
# database
database_name = "demo-db"
database_engine = "pg"
database_region = "blr1"
database_size = "db-s-1vcpu-1gb"
database_node_count = 1
database_cluster_version = "16"
```

## step 6: Spaces(bucket)
- create the spaces.tf file
- write the terraform script in it:

```hcl
module "spaces" {
    source        = "terraform-do-modules/spaces/digitalocean"
    version       = "1.0.0"
    name          = var.care_bucket_name
    environment   = "dev"
    acl           = "private"
    force_destroy = false
    region        = var.care_bucket_region
}
```

- then in variables.tf define the variables related to it

```hcl
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
```

- then in dev.tfvars file define the values of these variables

```hcl
# bucket
care_bucket_name = "demo-bucket"
care_bucket_region = "blr1"
care_bucket_key_name = "demo-bucket-key"
```

## step 7: Cloudfront
- create a cdn.tf file
- write the terraform script for it:

```hcl
module "cdn" {
    source             = "terraform-do-modules/cdn/digitalocean"
    version            = "1.0.0"
    origin             = module.spaces.bucket_domain_name
    ttl                = 3600
}
```

This is the cloudfront for caching the data, we will put this in front of the bucket.

## step 8: Backend app
- create the backend_app.tf
- so in this file we will define backend app, in backend app we have four components: redis, celery-worker, celery-beat, dajango app. so here we will define 2 services, 1 worker , 1 job in it.

```hcl
resource "digitalocean_app" "backend_app" {
  spec {
    name   = var.backend_app_name
    region = var.backend_app_region

    # domain {
    #   name = "care.api.example.com"
    # }

    dynamic "env" {
        for_each = local.backend_env_vars
        content {
          key   = env.value.key
          value = env.value.value
          type  = env.value.type
        }
    }

    service {
      name               = var.backend_redis_name
      instance_count     = 1
      instance_size_slug = var.backend_redis_instance_size
      internal_ports     = var.backend_redis_internal_ports

      image {
        registry_type  = "DOCKER_HUB"
        registry       = "redis"
        repository     = "redis-stack-server"
        tag            = var.backend_redis_tag
        deploy_on_push {
          enabled = true
        }
      }

      health_check {
        port                  = "6379"
        initial_delay_seconds = 5
        period_seconds        = 10
        timeout_seconds       = 5
        success_threshold     = 1
        failure_threshold     = 3
      }
  }

  service {
      name = var.backend_django_name

      instance_count     = 1
      instance_size_slug = var.backend_django_instance_size

      github {
        branch         = "develop"
        deploy_on_push = true
        repo           = "parth-18-bansal/care"
      }

      http_port  = var.backend_django_http_port

      build_command = "python install_plugins.py && python manage.py collectstatic --noinput && python manage.py compilemessages"
      run_command   = "gunicorn config.wsgi:application --workers 2 --bind :9000"

      health_check {
        port                  = "9000"
        initial_delay_seconds = 5
        period_seconds        = 10
        timeout_seconds       = 5
        success_threshold     = 1
        failure_threshold     = 3
      }
  }

  worker {
    name = var.backend_celery_worker_name

    instance_count = 1
    instance_size_slug = var.backend_celery_worker_instance_size

    github {
        branch         = "develop"
        deploy_on_push = true
        repo           = "parth-18-bansal/care"
    }

    build_command = "python install_plugins.py && python manage.py collectstatic --noinput && python manage.py compilemessages"
    run_command   = "celery --app=config.celery_app worker --max-tasks-per-child=2 --concurrency=2 --loglevel=DEBUG --logfile stdout"

  }

  job {
    name = var.backend_celery_beat_name

    instance_count = 1
    instance_size_slug = var.backend_celery_beat_instance_size

    kind = "POST_DEPLOY"

    github {
        branch         = "develop"
        deploy_on_push = true
        repo           = "parth-18-bansal/care"
    }

    build_command = "python install_plugins.py && python manage.py collectstatic --noinput && python manage.py compilemessages"
    run_command   = "python manage.py migrate"

  }
}

depends_on = [ module.spaces, module.postgresql ]
}
```

- defines variables for it in the variable.tf

```hcl
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
```

- then define the values of these variables
```hcl
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
```

Also backend app is using some envs so we have to define those also:
- creates a backend_envs.tf
- write the terraform script for it:

```hcl
locals {
  backend_env_vars = [
    {
        key   = "DJANGO_SETTINGS_MODULE"
        value = "config.settings.production"
        type  = "GENERAL"
    },
    {
        key   = "DATABASE_URL"
        value = module.postgresql.database_cluster_uri[0]
        type  = "SECRET"
    },
    {
        key   = "REDIS_URL"
        value = "redis://redis:6379"
        type  = "GENERAL"
    },
    {
        key   = "CORS_ALLOWED_ORIGINS"
        value = jsonencode([
        "https://care.example.com",
        "http://localhost:4000",
        "http://127.0.0.1:4000"
        ])
        type  = "GENERAL"
    },
    {
        key   = "CELERY_BROKER_URL"
        value = "redis://redis:6379"
        type  = "GENERAL"   
    },
    {
        key   = "REDIS_URL"
        value = "redis://redis:6379"
        type  = "GENERAL"
    },
    {
        key   = "BUCKET_PROVIDER"
        value = "DIGITAL_OCEAN"
        type  = "GENERAL"   
    },
    {
        key   = "BUCKET_REGION"
        value = var.care_bucket_region
        type  = "GENERAL"   
    },
    {
        key   = "BUCKET_KEY"
        value = var.spaces_access_key
        type  = "SECRET"   
    },
    {
        key   = "BUCKET_SECRET"
        value = var.spaces_secret_key
        type  = "SECRET"   
    },
    {
        key   = "BUCKET_HAS_FINE_ACL"
        value = "true"
        type  = "GENERAL"   
    },
    {
        key   = "FILE_UPLOAD_BUCKET"
        value = module.spaces.name
        type  = "GENERAL"   
    },
    {
        key   = "FILE_UPLOAD_BUCKET_ENDPOINT"
        value = "https://${module.spaces.name}.${var.care_bucket_region}.digitaloceanspaces.com"
        type  = "GENERAL"   
    },
    {
        key   = "FACILITY_S3_BUCKET"
        value = module.spaces.name
        type  = "GENERAL"   
    },
    {
        key   = "FACILITY_S3_BUCKET_ENDPOINT"
        value = "https://${module.spaces.name}.${var.care_bucket_region}.digitaloceanspaces.com"
        type  = "GENERAL"   
    },
    {
        key   = "JWKS_BASE64"
        value = "eyJrZXlzIjpbeyJrdHkiOiJSU0EiLCJhbGciOiJSUzI1NiIsInVzZSI6InNpZyIsIm4iOiJ6SmJUZXNSQ0dNemNtaUIwTUVORFJXOWxyLXZhb09xamIwV0E1UlVPQVVoMk9URF9DUm4xNXhKWHY5QkN5Mk0wOURVLXR1YVNSUm1PTGJOUUNhd3M1NDBwek55dmI0WnlQemxMR1Y1RDBQcFQtZE00NWZ5cjN0VXdXYXZqdkhNRThzMm1tM2QwamhtM1E2VmJjdWhlUmRhNFNYWjFBY0VSejRCRzRNMk9OT29GUXgwbWpzVlpzeXRDdnBxVnpiYTM4REFJbHRJMktsWS1ydU5YRXVkbUZITGlsWWRNcGpmc1NCSlRtTDBLc3FCc1NTS2lITXNpRXgxd2czNTdXeGpHX3BXZm1qbHR6ZXN3YkR0UWJ5UEhrRVBFWWdVT1o4bHhuTVNpMTkyWG9hZFZiMnhrd1NQQ1Fud3daZ1JmQjBfblFXNmY2eVh6ZkN4ZTBhX0k3bklOM1EiLCJlIjoiQVFBQiIsImtpZCI6ImE5YWJmMzM4ZjAifV19"
        type  = "GENERAL"   
    },
    {
        key   = "DISABLE_COLLECTSTATIC"
        value = "1"
        type  = "GENERAL"   
    }
  ]
}
```

## step 9: Frontend app
After this we have to define the frontend app

```hcl
resource "digitalocean_app" "frontend_app" {
  spec {
    name   = var.care_frontend_app_name
    region = var.care_frontend_app_region

    # domain {
    #   name = "care.example.com"
    # }

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

      error_document = "index.html"
    } 
  }
}
```

- Then define the corresponding variables in the variables.tf file

```hcl
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
```

- then define the values for these variables

```hcl
# care frontend
care_frontend_app_name = "care-frontend"
care_frontend_app_component_name = "care-frontend"
care_frontend_app_region = "blr1"
care_frontend_app_github_branch = "develop"
care_frontend_app_github_repo = "parth-18-bansal/care_fe"
```

- create a frontend_envs.tf file and define the envs for the frontend app in it

```hcl
locals {
  frontend_env_vars = [
    {
        key   = "REACT_CARE_API_URL"
        value = "https://${digitalocean_app.backend_app.live_domain}"
        type  = "GENERAL"
    },
  ]
}
```

## step 10: Bucket CORS  Configuration
- In spaces.tf, create one more resource like this

```hcl
resource "digitalocean_spaces_bucket_cors_configuration" "test" {
  bucket = module.spaces.name
  region = var.care_bucket_region

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST", "PUT", "DELETE"]
    allowed_origins = ["https://${digitalocean_app.frontend_app.live_domain}"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3600
  }
}
```

## step 11: Database Firewall Configuration

-- In database.tf, define the firewall configuration like this so only backend can access the database

```hcl
resource "digitalocean_database_firewall" "firewall" {
  cluster_id = module.postgresql.database_cluster_id[0]
  rule {
    type = "app"
    value = digitalocean_app.backend_app.id
  }
  depends_on = [module.postgresql, digitalocean_app.backend_app]
}
```

## step 12: Makefile

```bash
.PHONY: init prep plan deploy destroy lint

all: init plan deploy

init:
	@tofu init

plan: prep
	@tofu plan -var-file=environments/$(ENV).tfvars

deploy: prep
	@tofu apply -var-file=environments/$(ENV).tfvars -auto-approve

destroy: prep
	@tofu destroy -var-file=environments/$(ENV).tfvars

lint:
	@tofu fmt -write=true -recursive

```

## step 13: Infrastructure

In the terminal, just run the make

```bash
make
```









  




