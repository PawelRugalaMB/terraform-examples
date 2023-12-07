
#region VPC
resource "aws_vpc" "this" {
  cidr_block                       = var.cidr_block
  ipv4_ipam_pool_id                = var.vpc_ipv4_ipam_pool_id
  ipv4_netmask_length              = var.vpc_ipv4_netmask_length
  assign_generated_ipv6_cidr_block = var.vpc_assign_generated_ipv6_cidr_block
  ipv6_cidr_block                  = var.vpc_ipv6_cidr_block
  ipv6_ipam_pool_id                = var.vpc_ipv6_ipam_pool_id
  ipv6_netmask_length              = var.vpc_ipv6_netmask_length

  enable_dns_hostnames = var.vpc_enable_dns_hostnames
  enable_dns_support   = var.vpc_enable_dns_support

  tags = merge(
    { "Name" = var.name },
    var.tags
  )
}

#endregion

#region PUBLIC SUBNETS

resource "aws_subnet" "public" {
  for_each = contains(local.subnet_keys, "public") ? toset(local.azs) : toset([])

  availability_zone                              = each.key
  vpc_id                                         = local.vpc.id
  cidr_block                                     = can(local.calculated_subnets["public"][each.key]) ? local.calculated_subnets["public"][each.key] : null
  ipv6_cidr_block                                = can(local.calculated_subnets_ipv6["public"][each.key]) ? local.calculated_subnets_ipv6["public"][each.key] : null
  ipv6_native                                    = contains(local.subnets_with_ipv6_native, "public") ? true : false
  map_public_ip_on_launch                        = try(var.subnets.public.map_public_ip_on_launch, local.public_ipv6only ? null : true)
  assign_ipv6_address_on_creation                = local.public_ipv6only || local.public_dualstack ? true : null
  enable_resource_name_dns_aaaa_record_on_launch = local.public_ipv6only || local.public_dualstack ? true : false

  tags = merge(
    { Name = "${local.subnet_names["public"]}-${each.key}" },
    module.tags.tags_aws,
    try(module.subnet_tags["public"].tags_aws, {})
  )
}