output "client_instances" {
  description = "Client instance details"
  value       = module.clients[*].instance_details
}

output "storage_instances" {
  description = "Storage instance details"
  value       = module.storage_servers[*].instance_details
}
