output "vpc_id" {
  value = aws_vpc.this.id
}

output "private_route_table_id" {
  value = aws_route_table.private.id
}

output "private_subnet1_id" {
  value = aws_subnet.private-1.id
}

output "private_subnet2_id" {
  value = aws_subnet.private-2.id
}

output "public_subnet1_id" {
  value = aws_subnet.public-1.id
}

output "public_subnet2_id" {
  value = aws_subnet.public-2.id
}

output "public_subnet1_cidr" {
  value = aws_subnet.public-1.cidr_block
}