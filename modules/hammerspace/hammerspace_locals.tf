locals {
  # --- Anvil Creation Logic based on anvil_count ---
  should_create_any_anvils = var.anvil_count > 0
  create_standalone_anvil  = var.anvil_count == 1
  create_ha_anvils         = var.anvil_count >= 2

  # --- General Conditions ---
  provides_key_name      = var.key_name != null && var.key_name != ""
  enable_iam_admin_group = var.iam_user_access == "Enable"
  create_iam_admin_group = local.enable_iam_admin_group && var.iam_admin_group_id == ""
  create_profile         = var.profile_id == ""
  dsx_add_volumes_bool   = local.should_create_any_anvils && var.dsx_add_vols

  # --- Mappings & Derived Values ---
  anvil_instance_type_actual = var.anvil_type
  dsx_instance_type_actual   = var.dsx_type
  common_tags = merge(var.tags, {
    Project = var.project_name
  })

  device_letters = [
    "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
    "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"
  ]

  # --- IAM References ---
  effective_iam_admin_group_name = local.create_iam_admin_group ? (length(aws_iam_group.admin_group) > 0 ? aws_iam_group.admin_group[0].name : null) : var.iam_admin_group_id
  effective_iam_admin_group_arn  = local.create_iam_admin_group ? (length(aws_iam_group.admin_group) > 0 ? aws_iam_group.admin_group[0].arn : null) : (var.iam_admin_group_id != "" ? "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:group/${var.iam_admin_group_id}" : null)
  effective_instance_profile_ref = local.create_profile ? (length(aws_iam_instance_profile.profile) > 0 ? aws_iam_instance_profile.profile[0].name : null) : var.profile_id

  # --- Security Group Selection Logic ---
  effective_anvil_sg_id = var.anvil_security_group_id != "" ? var.anvil_security_group_id : (length(aws_security_group.anvil_data_sg) > 0 ? aws_security_group.anvil_data_sg[0].id : null)
  effective_dsx_sg_id   = var.dsx_security_group_id != "" ? var.dsx_security_group_id : (length(aws_security_group.dsx_sg) > 0 ? aws_security_group.dsx_sg[0].id : null)

  # --- IP and ID Discovery ---
  anvil2_ha_ni_secondary_ip = (
    local.create_ha_anvils &&
    length(aws_network_interface.anvil2_ha_ni) > 0 &&
    aws_network_interface.anvil2_ha_ni[0].private_ip != null &&
    length(tolist(aws_network_interface.anvil2_ha_ni[0].private_ips)) > 1
    ? ([for ip in tolist(aws_network_interface.anvil2_ha_ni[0].private_ips) : ip if ip != aws_network_interface.anvil2_ha_ni[0].private_ip][0])
    : null
  )

  management_ip_for_url = coalesce(
    local.anvil2_ha_ni_secondary_ip,
    local.create_standalone_anvil && length(aws_instance.anvil) > 0 ? aws_instance.anvil[0].private_ip : null,
    "N/A - Anvil instance details not available."
  )

  effective_anvil_ip_for_dsx_metadata = coalesce(
    local.anvil2_ha_ni_secondary_ip,
    local.create_standalone_anvil && length(aws_instance.anvil) > 0 ? aws_instance.anvil[0].private_ip : null
  )

  effective_anvil_id_for_dsx_password = coalesce(
    local.create_standalone_anvil && length(aws_instance.anvil) > 0 ? aws_instance.anvil[0].id : null,
    local.create_ha_anvils && length(aws_instance.anvil1) > 0 ? aws_instance.anvil1[0].id : null
  )

  # --- UserData String Construction (Simplified) ---

  # Create a helper for the optional 'aws' config section
  aws_config_string_part = local.enable_iam_admin_group && local.effective_iam_admin_group_name != null ? "iam_admin_group: ${local.effective_iam_admin_group_name}" : ""

  # Standalone Anvil UserData
  anvil_sa_userdata = local.create_standalone_anvil ? format(
    "{cluster: {password_auth: False}, node: {hostname: %s, ha_mode: Standalone, networks: {eth0: {roles: [data, mgmt]}}}, aws: {%s}}",
    "${var.project_name}Anvil",
    local.aws_config_string_part
  ) : null

  # MODIFIED: Logic for HA Anvil UserData to match the new required format
  # First, create the common string for the cluster definition
  ha_cluster_definition_string = local.create_ha_anvils ? format(
    "{cluster: {password_auth: False}, aws: {%s}, nodes: {'0': {hostname: %s, ha_mode: Primary, features: [metadata], networks: {eth0: {roles: [data, mgmt, ha]}}}, '1': {hostname: %s, ha_mode: Secondary, features: [metadata], networks: {eth0: {roles: [data, mgmt, ha]}}}}}",
    local.aws_config_string_part,
    "${var.project_name}Anvil1",
    "${var.project_name}Anvil2"
  ) : ""
  
  # Then, construct the final UserData for each node by prepending the unique node_index
  anvil1_ha_userdata = local.create_ha_anvils ? format(
    "{node_index: '0', %s", 
    trimprefix(local.ha_cluster_definition_string, "{")
  ) : null

  anvil2_ha_userdata = local.create_ha_anvils ? format(
    "{node_index: '1', %s", 
    trimprefix(local.ha_cluster_definition_string, "{")
  ) : null

  # --- DSX Node Configuration Helper ---
  # This creates the string that defines the Anvil nodes for the DSX config.
  dsx_anvils_nodes_config_string = local.create_standalone_anvil ? "'1': {hostname: ${var.project_name}Anvil, features: [metadata]}" : (local.create_ha_anvils ? "'1': {hostname: ${var.project_name}Anvil1, features: [metadata]}, '2': {hostname: ${var.project_name}Anvil2, features: [metadata]}" : "")
}
