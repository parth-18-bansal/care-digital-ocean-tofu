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

## step 2: write the provider.tf
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

## step 3: write the init.tf
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

## step 5: next we will create the postgres database
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

## step 6: now we will define the spaces(bucket)
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
- so in this file we will define backend app, in backend app we have four components: redis, celery-worker, celery-beat, dajango app. so here we will define four services in it.

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







  




