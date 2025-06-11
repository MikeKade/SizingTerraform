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

  # IAM References
  effective_iam_admin_group_name = local.create_iam_admin_group ? (length(aws_iam_group.admin_group) > 0 ? aws_iam_group.admin_group[0].name : null) : var.iam_admin_group_id
  effective_iam_admin_group_arn  = local.create_iam_admin_group ? (length(aws_iam_group.admin_group) > 0 ? aws_iam_group.admin_group[0].arn : null) : (var.iam_admin_group_id != "" ? "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:group/${var.iam_admin_group_id}" : null)
  effective_instance_profile_ref = local.create_profile ? (length(aws_iam_instance_profile.profile) > 0 ? aws_iam_instance_profile.profile[0].name : null) : var.profile_id

  # --- UserData Configuration ---
  anvil_sa_userdata_rendered = local.create_standalone_anvil ? templatefile("${path.module}/templates/anvil_sa.tftpl", {
    project_name   = var.project_name,
    admin_config_param = local.enable_iam_admin_group && local.effective_iam_admin_group_name != null ? ", aws: {iam_admin_group: \"${local.effective_iam_admin_group_name}\"}" : ""
  }) : null

  anvil1_ha_userdata_rendered = local.create_ha_anvils ? templatefile("${path.module}/templates/anvil1_ha.tftpl", {
    project_name        = var.project_name,
    admin_config_param      = local.enable_iam_admin_group && local.effective_iam_admin_group_name != null ? "iam_admin_group: \"${local.effective_iam_admin_group_name}\"" : "",
    cluster_ip_config_param = local.create_ha_anvils && local.anvil2_ha_ni_secondary_ip != null ? ", cluster_ips: [\"${local.anvil2_ha_ni_secondary_ip}\"]" : ""
  }) : null

  anvil2_ha_userdata_rendered = local.create_ha_anvils ? templatefile("${path.module}/templates/anvil2_ha.tftpl", {
    project_name        = var.project_name,
    admin_config_param      = local.enable_iam_admin_group && local.effective_iam_admin_group_name != null ? "iam_admin_group: \"${local.effective_iam_admin_group_name}\"" : "",
    cluster_ip_config_param = local.create_ha_anvils && local.anvil2_ha_ni_secondary_ip != null ? ", cluster_ips: [\"${local.anvil2_ha_ni_secondary_ip}\"]" : ""
  }) : null

  anvil_sa_user_data_b64  = local.anvil_sa_userdata_rendered != null ? base64encode(local.anvil_sa_userdata_rendered) : ""
  anvil1_ha_user_data_b64 = local.anvil1_ha_userdata_rendered != null ? base64encode(local.anvil1_ha_userdata_rendered) : ""
  anvil2_ha_user_data_b64 = local.anvil2_ha_userdata_rendered != null ? base64encode(local.anvil2_ha_userdata_rendered) : ""

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

  dsx_anvils_nodes_config_string = local.should_create_any_anvils ? (
                                    local.create_ha_anvils ? "'1': {hostname: \"${var.project_name}Anvil1\", features: [metadata]}, '2': {hostname: \"${var.project_name}Anvil2\", features: [metadata]}" :
                                    (local.create_standalone_anvil ? "'1': {hostname: \"${var.project_name}Anvil\", features: [metadata]}" : "")
                                  ) : ""

  dsx_user_data_template_vars_base = {
    password_auth_pwd_suffix = local.effective_anvil_id_for_dsx_password != null ? ", password: \"${local.effective_anvil_id_for_dsx_password}\"" : ""
    metadata_ip_for_dsx      = local.effective_anvil_ip_for_dsx_metadata != null ? "\"${local.effective_anvil_ip_for_dsx_metadata}/20\"" : "\"CONFIGURE_ANVIL_IP/20\""
    add_volumes_str          = local.dsx_add_volumes_bool ? "true" : "false"
    admin_config_suffix      = local.enable_iam_admin_group && local.effective_iam_admin_group_name != null ? ", aws: {iam_admin_group: \"${local.effective_iam_admin_group_name}\"}" : ""
    anvils_config_for_dsx    = local.dsx_anvils_nodes_config_string
    project_name             = var.project_name
  }

  dsx_node1_userdata_rendered = var.dsx_count > 0 ? templatefile("${path.module}/templates/dsx.tftpl", merge(
    local.dsx_user_data_template_vars_base,
    { dsx_node_index_param = 1 }
  )) : null

  block_device_root_config = {
    volume_type = "gp3"
    volume_size = 200
  }

  device_letters = [
    "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
    "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"
  ]
}
