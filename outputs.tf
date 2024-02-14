output "public_route_tables" {
  value = aws_route_table.public-route-table
}
output "private_subnets" {
  value = aws_subnet.private_subnets
}
output "public_subnets" {
  value = aws_subnet.public_subnets
}