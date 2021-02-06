data "aws_route53_zone" "public" {
  name = var.zone_name
}

module "redis" {
  count = var.cache_store == "redis" ? 1 : 0

  source  = "cloudposse/elasticache-redis/aws"
  version = "0.30.0"

  name = "redis"

  vpc_id               = var.vpc_id
  namespace            = var.project
  stage                = var.environment
  subnets              = var.subnet_ids
  availability_zones   = var.availability_zones
  replication_group_id = "${var.project}-${var.environment}-cache"

  family         = var.redis_family
  engine_version = var.redis_engine_version
  instance_type  = var.instance_type
  cluster_size   = var.cluster_size

  allowed_security_groups = var.security_groups

  zone_id = data.aws_route53_zone.public.zone_id

  cloudwatch_metric_alarms_enabled = true

  parameter = [
    {
      name  = "notify-keyspace-events"
      value = "lK"
    }
  ]

  apply_immediately = true
}

module "memcached" {
  count = var.cache_store == "memcached" ? 1 : 0

  source  = "cloudposse/elasticache-memcached/aws"
  version = "0.10.0"

  name = "memcached"

  vpc_id             = var.vpc_id
  namespace          = var.project
  stage              = var.environment
  cluster_size       = var.cluster_size
  subnets            = var.subnet_ids
  availability_zones = var.availability_zones

  zone_id = data.aws_route53_zone.public.zone_id

  allowed_security_groups = var.security_groups

  engine_version = var.memcached_engine_version
  instance_type  = var.instance_type

  apply_immediately = true
}
