resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = merge(
    var.tags ,
    { Name = "${var.env}-vpc"}
  )
}

## Public Subnets

resource "aws_subnet" "public_subnets" {
  vpc_id = aws_vpc.main.id # the main vpc that we created above

  for_each = var.public_subnets
  cidr_block = each.value["cidr_block"]
  availability_zone = each.value["availability_zone"]
  tags = merge(
    var.tags ,
    { Name = "${var.env}-${each.value["name"]}"}
  )
}
# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    var.tags ,
    { Name = "${var.env}-igw"}
  )
}
# elastic Ip
resource "aws_eip" "nat_eip" {
  for_each = var.public_subnets
  vpc = true ## this has been depracated , we have to use domain instead , learn yourself on this
  tags = merge(
    var.tags ,
    { Name = "${var.env}-${each.value["name"]}-elastic-ip"}
  )
}

# Nat Gateway
resource "aws_nat_gateway" "nat_gateways" {
  for_each = var.public_subnets
  allocation_id = aws_eip.nat_eip[each.value["name"]].id
  subnet_id = aws_subnet.public_subnets[each.value["name"]].id
  tags = merge(
    var.tags ,
    { Name = "${var.env}-${each.value["name"]}-nat-gateway"}
  )
}

##Public Route Tables
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  for_each = var.public_subnets
  tags = merge(
    var.tags ,
    { Name = "${var.env}-${each.value["name"]}-route_table"} # adding route_table at the end for better understanding
  )

}

# Public route table association
resource "aws_route_table_association" "public-association" {
  for_each = var.public_subnets
  subnet_id = aws_subnet.public_subnets[each.value["name"]].id
#  route_table_id = aws_route_table.public-route-table[each.value["name"]].id
  route_table_id = lookup(lookup(aws_route_table.public-route-table, each.value["name"] , null ), "id" , null )

}



## Private Subnets
resource "aws_subnet" "private_subnets" {
  vpc_id = aws_vpc.main.id # the main vpc that we created above

  for_each = var.private_subnets
  cidr_block = each.value["cidr_block"]
  availability_zone = each.value["availability_zone"]
  tags = merge(
    var.tags ,
    { Name = "${var.env}-${each.value["name"]}"}
  )
}

# Private Route Tables
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.main.id
  for_each = var.private_subnets

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateways["public-${split("-", each.value["name"])[1]}"].id
  }


  tags = merge(
    var.tags ,
    { Name = "${var.env}-${each.value["name"]}-route_table"} # adding route_table at the end for better understanding
  )

}
# Private route table association
resource "aws_route_table_association" "private-association" {
  for_each = var.private_subnets
  subnet_id = aws_subnet.private_subnets[each.value["name"]].id
  route_table_id = aws_route_table.private-route-table[each.value["name"]].id
#  route_table_id = lookup(lookup(aws_route_table.public-route-table, each.value["name"] , null ), "id" , null )

}

