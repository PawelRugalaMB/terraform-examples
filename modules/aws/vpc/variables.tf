#region VPC
variable "name" {
    description = "The name of the VPC"
    type        = string
    default     = ""
}

variable "cidr" {
    description = "(Optional) IPv4 CIDR block for the vpc"
    type        = string
    default     = "10.0.0.0/16"
}

variable "azs" {
    description = "A list of availability zones names or ids in the region"
    type        = list(string)
    default     = []
}

variable "enable_network_metrics" {
    description = "(Optional) Enable/disable detailed monitoring. This is enabled by default."
    type        = bool
    default     = null
}

variable "tags" {
    description = "(Optional) A mapping of tags to assign to the resource"
    type        = map(string)
    default     = {}
}
#endregion

#region Public Subnets

#endregion

#region Private Subnets

#endregion

#region Internet Gateway

#endregion

#region NAT Gateway

#endregion