output "client_instances" {
  description = "Client instance details"
  value       = module.clients[*].instance_details
}

output "storage_instances" {
  description = "Storage instance details"
  value       = module.storage_servers[*].instance_details
}

output "hammerspace_anvil" {
  description = "Hammerspace Anvil details"
  value       = module.hammerspace[*].anvil_instances
  sensitive   = true
}

output "hammerspace_dsx" {
  description = "Hammerspace DSX details"
  value       = module.hammerspace[*].dsx_instances
}

output "hammerspace_mgmt_ip" {
  description = "Hammerspace Mgmt IP"
  value       = module.hammerspace[*].management_ip
}

output "hammerspace_mgmt_url" {
  description = "Hammerspace Mgmt URL"
  value       = module.hammerspace[*].management_url
}

output "hammerspace_dsx_node1_rendered_userdata" {
  description = "Rendered UserData for the first DSX node in the Hammerspace module."
  value       = local.deploy_hammerspace ? module.hammerspace[0].dsx_node1_userdata_rendered : null
  sensitive   = true
}