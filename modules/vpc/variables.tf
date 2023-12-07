variable "name" {
  type        = string
  description = "The name of the VPC"
}

variable "cidr_block" {
  type        = string
  default     = null
  description = "The CIDR block for the VPC"
}

variable "vpc_ipv4_ipam_pool_id" {
  description = "Set to use IPAM to get an IPv4 CIDR block."
  type        = string
  default     = null
}

variable "vpc_ipv4_netmask_length" {
  description = "Set to use IPAM to get an IPv4 CIDR block using a specified netmask. Must be set with var.vpc_ipv4_ipam_pool_id."
  type        = string
  default     = null
}

variable "vpc_assign_generated_ipv6_cidr_block" {
  description = "Requests and Amazon-provided IPv6 CIDR block with a /56 prefix length. You cannot specify the range of IP addresses, or the size of the CIDR block. Conflicts with `vpc_ipv6_ipam_pool_id`."
  type        = bool
  default     = null
}

variable "vpc_ipv6_cidr_block" {
  description = "IPv6 CIDR range to assign to VPC if creating VPC. You need to use `vpc_ipv6_ipam_pool_id` and set explicitly the CIDR block to use, or derived from IPAM using using `vpc_ipv6_netmask_length`."
  type        = string
  default     = null
}

variable "vpc_ipv6_ipam_pool_id" {
  description = "Set to use IPAM to get an IPv6 CIDR block."
  type        = string
  default     = null
}

variable "vpc_ipv6_netmask_length" {
  description = "Set to use IPAM to get an IPv6 CIDR block using a specified netmask. Must be set with `var.vpc_ipv6_ipam_pool_id`."
  type        = string
  default     = null
}

variable "vpc_enable_dns_hostnames" {
  type        = bool
  description = "Indicates whether the instances launched in the VPC get DNS hostnames. If enabled, instances in the VPC get DNS hostnames; otherwise, they do not. Disabled by default for nondefault VPCs."
  default     = true
}

variable "vpc_enable_dns_support" {
  type        = bool
  description = "Indicates whether the DNS resolution is supported for the VPC. If enabled, queries to the Amazon provided DNS server at the 169.254.169.253 IP address, or the reserved IP address at the base of the VPC network range \"plus two\" succeed. If disabled, the Amazon provided DNS service in the VPC that resolves public DNS hostnames to IP addresses is not enabled. Enabled by default."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "az_count" {
  type        = number
  description = "Searches region for # of AZs to use and takes a slice based on count. Assume slice is sorted a-z."
}

variable "subnets" {
  description = <<-EOF
  Configuration of subnets to build in VPC. 1 Subnet per AZ is created. Subnet types are defined as maps with the available keys: "private", "public", "transit_gateway", "core_network". Each Subnet type offers its own set of available arguments detailed below.

  **Attributes shared across subnet types:**
  - `cidrs`            = (Optional|list(string)) **Cannot set if `netmask` is set.** List of IPv4 CIDRs to set to subnets. Count of CIDRs defined must match quantity of azs in `az_count`.
  - `netmask`          = (Optional|Int) **Cannot set if `cidrs` is set.** Netmask of the `var.cidr_block` to calculate for each subnet.
  - `assign_ipv6_cidr` = (Optional|bool) **Cannot set if `ipv6_cidrs` is set.** If true, it will calculate a /64 block from the IPv6 VPC CIDR to set in the subnets.
  - `ipv6_cidrs`       = (Optional|list(string)) **Cannot set if `assign_ipv6_cidr` is set.** List of IPv6 CIDRs to set to subnets. The subnet size must use a /64 prefix length. Count of CIDRs defined must match quantity of azs in `az_count`.
  - `name_prefix`      = (Optional|String) A string prefix to use for the name of your subnet and associated resources. Subnet type key name is used if omitted (aka private, public, transit_gateway). Example `name_prefix = "private"` for `var.subnets.private` is redundant.
  - `tags`             = (Optional|map(string)) Tags to set on the subnet and associated resources.

  **Any private subnet type options:**
  - All shared keys above
  - `connect_to_public_natgw` = (Optional|bool) Determines if routes to NAT Gateways should be created. Must also set `var.subnets.public.nat_gateway_configuration` in public subnets.
  - `ipv6_native`             = (Optional|bool) Indicates whether to create an IPv6-ony subnet. Either `var.assign_ipv6_cidr` or `var.ipv6_cidrs` should be defined to allocate an IPv6 CIDR block.
  - `connect_to_eigw`         = (Optional|bool) Determines if routes to the Egress-only Internet gateway should be created. Must also set `var.vpc_egress_only_internet_gateway`.

  **public subnet type options:**
  - All shared keys above
  - `nat_gateway_configuration` = (Optional|string) Determines if NAT Gateways should be created and in how many AZs. Valid values = `"none"`, `"single_az"`, `"all_azs"`. Default = "none". Must also set `var.subnets.private.connect_to_public_natgw = true`.
  - `connect_to_igw`            = (Optional|bool) Determines if the default route (0.0.0.0/0 or ::/0) is created in the public subnets with destination the Internet gateway. Defaults to `true`.
  - `ipv6_native`               = (Optional|bool) Indicates whether to create an IPv6-ony subnet. Either `var.assign_ipv6_cidr` or `var.ipv6_cidrs` should be defined to allocate an IPv6 CIDR block.
  - `map_public_ip_on_launch`   = (Optional|bool) Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default to `false`.

  **transit_gateway subnet type options:**
  - All shared keys above
  - `connect_to_public_natgw`                         = (Optional|string) Determines if routes to NAT Gateways should be created. Specify the CIDR range or a prefix-list-id that you want routed to nat gateway. Usually `0.0.0.0/0`. Must also set `var.subnets.public.nat_gateway_configuration`.
  - `transit_gateway_default_route_table_association` = (Optional|bool) Boolean whether the VPC Attachment should be associated with the EC2 Transit Gateway association default route table. This cannot be configured or perform drift detection with Resource Access Manager shared EC2 Transit Gateways.
  - `transit_gateway_default_route_table_propagation` = (Optional|bool) Boolean whether the VPC Attachment should propagate routes with the EC2 Transit Gateway propagation default route table. This cannot be configured or perform drift detection with Resource Access Manager shared EC2 Transit Gateways.
  - `transit_gateway_appliance_mode_support`          = (Optional|string) Whether Appliance Mode is enabled. If enabled, a traffic flow between a source and a destination uses the same Availability Zone for the VPC attachment for the lifetime of that flow. Valid values: `disable` (default) and `enable`.
  - `transit_gateway_dns_support`                     = (Optional|string) DNS Support is used if you need the VPC to resolve public IPv4 DNS host names to private IPv4 addresses when queried from instances in another VPC attached to the transit gateway. Valid values: `enable` (default) and `disable`.

  **core_network subnet type options:**
  - All shared keys abovce
  - `connect_to_public_natgw` = (Optional|string) Determines if routes to NAT Gateways should be created. Specify the CIDR range or a prefix-list-id that you want routed to nat gateway. Usually `0.0.0.0/0`. Must also set `var.subnets.public.nat_gateway_configuration`.
  - `appliance_mode_support`  = (Optional|bool) Indicates whether appliance mode is supported. If enabled, traffic flow between a source and destination use the same Availability Zone for the VPC attachment for the lifetime of that flow. Defaults to `false`.
  - `require_acceptance`      = (Optional|bool) Boolean whether the core network VPC attachment to create requires acceptance or not. Defaults to `false`.
  - `accept_attachment`       = (Optional|bool) Boolean whether the core network VPC attachment is accepted or not in the segment. Only valid if `require_acceptance` is set to `true`. Defaults to `true`.
  ```
EOF
  type        = any

  # All var.subnets.public valid keys
  validation {
    error_message = "Invalid key in public subnets. Valid options include: \"cidrs\", \"netmask\", \"name_prefix\", \"connect_to_igw\", \"nat_gateway_configuration\", \"ipv6_native\", \"assign_ipv6_cidr\", \"ipv6_cidrs\", \"tags\"."
    condition = length(setsubtract(keys(try(var.subnets.public, {})), [
      "cidrs",
      "netmask",
      "name_prefix",
      "connect_to_igw",
      "nat_gateway_configuration",
      "ipv6_native",
      "assign_ipv6_cidr",
      "ipv6_cidrs",
      "map_public_ip_on_launch",
      "tags"
    ])) == 0
  }

  # All var.subnets.transit_gateway valid keys
  validation {
    error_message = "Invalid key in transit_gateway subnets. Valid options include: \"cidrs\", \"netmask\", \"name_prefix\", \"connect_to_public_natgw\", \"assign_ipv6_cidr\", \"ipv6_cidrs\", \"transit_gateway_default_route_table_association\", \"transit_gateway_default_route_table_propagation\", \"transit_gateway_appliance_mode_support\", \"transit_gateway_dns_support\", \"tags\"."
    condition = length(setsubtract(keys(try(var.subnets.transit_gateway, {})), [
      "cidrs",
      "netmask",
      "name_prefix",
      "connect_to_public_natgw",
      "assign_ipv6_cidr",
      "ipv6_cidrs",
      "transit_gateway_default_route_table_association",
      "transit_gateway_default_route_table_propagation",
      "transit_gateway_appliance_mode_support",
      "transit_gateway_dns_support",
      "tags"
    ])) == 0
  }

  # All var.subnets.core_network valid keys
  validation {
    error_message = "Invalid key in core_network subnets. Valid options include: \"cidrs\", \"netmask\", \"name_prefix\", \"connect_to_public_natgw\", \"assign_ipv6_cidr\", \"ipv6_cidrs\", \"appliance_mode_support\", \"require_acceptance\", \"accept_attachment\", \"tags\"."
    condition = length(setsubtract(keys(try(var.subnets.core_network, {})), [
      "cidrs",
      "netmask",
      "name_prefix",
      "connect_to_public_natgw",
      "assign_ipv6_cidr",
      "ipv6_cidrs",
      "appliance_mode_support",
      "require_acceptance",
      "accept_attachment",
      "tags"
    ])) == 0
  }

  validation {
    error_message = "Each subnet type must contain only 1 key: `cidrs` or `netmask` or `ipv6_native`."
    condition     = alltrue([for subnet_type, v in var.subnets : length(setintersection(keys(v), ["cidrs", "netmask", "ipv6_native"])) == 1])
  }

  validation {
    error_message = "Public subnet `nat_gateway_configuration` can only be `all_azs`, `single_az`, `none`, or `null`."
    condition     = can(regex("^(all_azs|single_az|none)$", var.subnets.public.nat_gateway_configuration)) || try(var.subnets.public.nat_gateway_configuration, null) == null
  }

  validation {
    error_message = "Any subnet type `name_prefix` must not contain \"/\"."
    condition     = alltrue([for _, v in var.subnets : !can(regex("/", try(v.name_prefix, "")))])
  }
}