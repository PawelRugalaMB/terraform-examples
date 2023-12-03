#region VPC
resource "aws_vpc" "this" {
    cidr_block = var.cidr

    tags = var.tags
}

//aws_subnet public
//aws_subnet private

//aws_internet_gateway

//aws_eip

//aws_nat_gateway

//aws_route_table public
//aws_route_table_association public

//aws_route_table private
//aws_route_table_association private

//aws_security_group