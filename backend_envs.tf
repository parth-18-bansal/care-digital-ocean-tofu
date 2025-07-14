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
        value = "blr1"
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
        key   = "DISABLE_COLLECTSTATI"
        value = "1"
        type  = "GENERAL"   
    }
  ]
}
