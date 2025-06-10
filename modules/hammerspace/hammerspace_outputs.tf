output "management_ip" {
  description = "Management IP address for the Hammerspace cluster. This could be the ClusterIP parameter, or a secondary IP on Anvil2 for HA if not using ClusterIP, or Anvil's private IP for standalone."
  value       = local.management_ip_for_url
}

output "management_url" {
  description = "Management URL for the Hammerspace cluster."
  value       = local.management_ip_for_url != "N/A - Configure ClusterIP or check Anvil instance details." ? "https://${local.management_ip_for_url}" : "N/A"
}

output "anvil_instances" {
  description = "Details of deployed Anvil instances. A list containing one map for standalone, or two maps for HA."
  sensitive   = true
  value = local.create_standalone_anvil && length(aws_instance.anvil) > 0 ? [
    {
      type                       = "standalone"
      id                         = aws_instance.anvil[0].id
      arn                        = aws_instance.anvil[0].arn
      private_ip                 = aws_instance.anvil[0].private_ip
      public_ip                  = aws_instance.anvil[0].public_ip
      key_name                   = aws_instance.anvil[0].key_name
      iam_profile                = aws_instance.anvil[0].iam_instance_profile
      placement_group            = aws_instance.anvil[0].placement_group
      all_private_ips_on_eni_set = toset([])
      floating_ip_candidate      = null
    }
  ] : (local.create_ha_anvils ? [
    { # Anvil1
      type                       = "ha_node1"
      id                         = length(aws_instance.anvil1) > 0 ? aws_instance.anvil1[0].id : null
      arn                        = length(aws_instance.anvil1) > 0 ? aws_instance.anvil1[0].arn : null
      private_ip                 = length(aws_instance.anvil1) > 0 ? aws_instance.anvil1[0].private_ip : null
      public_ip                  = length(aws_instance.anvil1) > 0 ? aws_instance.anvil1[0].public_ip : null
      key_name                   = length(aws_instance.anvil1) > 0 ? aws_instance.anvil1[0].key_name : null
      iam_profile                = length(aws_instance.anvil1) > 0 ? aws_instance.anvil1[0].iam_instance_profile : null
      placement_group            = length(aws_instance.anvil1) > 0 ? aws_instance.anvil1[0].placement_group : null
      all_private_ips_on_eni_set = toset([])
      floating_ip_candidate      = null
    },
    { # Anvil2
      type                       = "ha_node2"
      id                         = length(aws_instance.anvil2) > 0 ? aws_instance.anvil2[0].id : null
      arn                        = length(aws_instance.anvil2) > 0 ? aws_instance.anvil2[0].arn : null
      private_ip                 = length(aws_instance.anvil2) > 0 ? aws_instance.anvil2[0].private_ip : null
      public_ip                  = length(aws_instance.anvil2) > 0 ? aws_instance.anvil2[0].public_ip : null
      key_name                   = length(aws_instance.anvil2) > 0 ? aws_instance.anvil2[0].key_name : null
      iam_profile                = length(aws_instance.anvil2) > 0 ? aws_instance.anvil2[0].iam_instance_profile : null
      placement_group            = length(aws_instance.anvil2) > 0 ? aws_instance.anvil2[0].placement_group : null
      all_private_ips_on_eni_set = length(aws_network_interface.anvil2_ha_ni) > 0 ? aws_network_interface.anvil2_ha_ni[0].private_ips : toset([])
      floating_ip_candidate      = local.anvil2_ha_ni_secondary_ip
    }
  ] : [])
}

output "dsx_instances" {
  description = "Details of deployed DSX instances."
  value = [
    for i, inst in aws_instance.dsx : {
      index           = i + 1
      id              = inst.id
      arn             = inst.arn
      private_ip      = inst.private_ip
      public_ip       = inst.public_ip
      key_name        = inst.key_name
      iam_profile     = inst.iam_instance_profile
      placement_group = inst.placement_group
    }
  ]
}

output "primary_management_anvil_instance_id" {
  description = "Instance ID of the primary Anvil node (Anvil for Standalone, Anvil1 for HA)."
  value = coalesce(
    local.create_standalone_anvil && length(aws_instance.anvil) > 0 ? aws_instance.anvil[0].id : null,
    local.create_ha_anvils && length(aws_instance.anvil1) > 0 ? aws_instance.anvil1[0].id : null,
    null
  )
}

output "iam_admin_group_name" {
  description = "Name of the IAM Admin Group, if configured and enabled."
  value       = local.enable_iam_admin_group ? local.effective_iam_admin_group_name : "IAM Admin Group access not enabled."
}

output "iam_admin_group_console_url" {
  description = "If an IAM Admin Group was enabled/created, URL to access it in the AWS Console."
  value       = local.enable_iam_admin_group && local.effective_iam_admin_group_name != null ? "https://console.aws.amazon.com/iam/home?#groups/${local.effective_iam_admin_group_name}" : "IAM Admin Group access not enabled or group name not determined."
}

output "anvil_standalone_userdata_rendered" {
  description = "Rendered UserData for the Standalone Anvil instance (if created)."
  value       = local.anvil_sa_userdata_rendered
  sensitive   = true
}

output "anvil_ha_node1_userdata_rendered" {
  description = "Rendered UserData for Anvil HA Node 1 (if created)."
  value       = local.anvil1_ha_userdata_rendered
  sensitive   = true
}

output "anvil_ha_node2_userdata_rendered" {
  description = "Rendered UserData for Anvil HA Node 2 (if created)."
  value       = local.anvil2_ha_userdata_rendered
  sensitive   = true
}

output "dsx_userdata_rendered" {
  description = "Rendered UserData for the first DSX node (if any DSX nodes are created)."
  value       = local.dsx_node1_userdata_rendered
  sensitive   = true
}
