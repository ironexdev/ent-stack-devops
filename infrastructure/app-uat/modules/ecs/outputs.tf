output "ecs_instance_public_ip" {
  value = aws_eip.ecs_instance_eip.public_ip
}

output "ecs_instance_id" {
  value = aws_instance.ecs_instance.id
}

output "ecs_cluster_id" {
  value = aws_ecs_cluster.ent-uat-cluster.id
}

output "ecs_instance_eip" {
  value = aws_eip.ecs_instance_eip.public_ip
}