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
