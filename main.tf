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
  tags = merge(
    var.tags ,
    { Name = "${var.env}-${each.value["name"]}"}
  )
  for_each = var.public_subnets
  cidr_block = each.value["cidr_block"]
  availability_zone = each.value["availability_zone"]
}
resource "aws_subnet" "private_subnets" {
  vpc_id = aws_vpc.main.id # the main vpc that we created above
  tags = merge(
    var.tags ,
    { Name = "${var.env}-${each.value["name"]}"}
  )
  for_each = var.private_subnets
  cidr_block = each.value["cidr_block"]
  availability_zone = each.value["availability_zone"]
}