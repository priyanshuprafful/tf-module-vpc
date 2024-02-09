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

##Public Route Tables
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.main.id

  for_each = var.public_subnets
  tags = merge(
    var.tags ,
    { Name = "${var.env}-${each.value["name"]}-route_table"} # adding route_table at the end for better understanding
  )

}

resource "aws_route_table_association" "public-association" {
  for_each = var.public_subnets
  subnet_id = aws_subnet.public_subnets[each.value["name"]].id
#  route_table_id = aws_route_table.public-route-table[each.value["name"]].id
  route_table_id = lookup(lookup(aws_route_table.public-route-table, [each.value["name"]] , null ), "id" , null )

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
  tags = merge(
    var.tags ,
    { Name = "${var.env}-${each.value["name"]}-route_table"} # adding route_table at the end for better understanding
  )

}