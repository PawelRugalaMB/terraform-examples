data "aws_availability_zones" "current" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}


locals {
    azs = slice(data.aws_availability_zones.current.name, 0, var.az_count)
    subnet_keys           = keys(var.subnets)
}