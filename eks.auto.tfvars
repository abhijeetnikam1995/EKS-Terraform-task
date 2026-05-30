cluster_name = "eksdemo1"
cluster_service_ipv4_cidr = "172.20.0.0/16"
cluster_version = "1.32"
cluster_endpoint_private_access = false
cluster_endpoint_public_access = true
cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]
cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
cluster_log_retention_in_days = 30
