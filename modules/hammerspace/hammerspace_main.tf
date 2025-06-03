# --- IAM Resources ---
resource "aws_iam_group" "admin_group" {
  count = local.create_iam_admin_group ? 1 : 0
  name  = var.iam_admin_group_id != "" ? var.iam_admin_group_id : "${var.project_name}-AnvilAdminGroup" # Using var.project_name as prefix
  path  = "/users/"
}

resource "aws_iam_role" "instance_role" {
  count = local.create_profile ? 1 : 0
  name  = "${var.project_name}-InstanceRole" # Using var.project_name as prefix
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
  tags = local.common_tags
}

resource "aws_iam_role_policy" "ssh_policy" {
  count = local.create_profile ? 1 : 0
  name  = "IAMAccessSshPolicy"
  role  = aws_iam_role.instance_role[0].id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid    = "1", Effect = "Allow", Action = ["iam:ListSSHPublicKeys", "iam:GetSSHPublicKey", "iam:GetGroup"],
      Resource = compact(["arn:${data.aws_partition.current.partition}:iam::*:user/*", local.effective_iam_admin_group_arn])
    }]
  })
}

resource "aws_iam_role_policy" "ha_instance_policy" {
  count = local.create_profile ? 1 : 0
  name  = "HAInstancePolicy"
  role  = aws_iam_role.instance_role[0].id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Sid = "2", Effect = "Allow", Action = ["ec2:DescribeInstances", "ec2:DescribeInstanceAttribute", "ec2:DescribeTags"], Resource = ["*"] }]
  })
}

resource "aws_iam_role_policy" "floating_ip_policy" {
  count = local.create_profile ? 1 : 0
  name  = "FloatingIpPolicy"
  role  = aws_iam_role.instance_role[0].id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Sid = "3", Effect = "Allow", Action = ["ec2:AssignPrivateIpAddresses", "ec2:UnassignPrivateIpAddresses"], Resource = ["*"] }]
  })
}

resource "aws_iam_role_policy" "anvil_metering_policy" {
  count = local.create_profile ? 1 : 0
  name  = "AnvilMeteringPolicy"
  role  = aws_iam_role.instance_role[0].id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Sid = "4", Effect = "Allow", Action = ["aws-marketplace:MeterUsage"], Resource = ["*"] }]
  })
}

resource "aws_iam_instance_profile" "profile" {
  count = local.create_profile ? 1 : 0
  name  = "${var.project_name}-InstanceProfile" # Using var.project_name as prefix
  role  = aws_iam_role.instance_role[0].name
  tags  = local.common_tags
}

# --- Security Groups ---
resource "aws_security_group" "anvil_data_sg" {
  count       = local.should_create_any_anvils ? 1 : 0
  name        = "${var.project_name}-AnvilDataSG" # Using var.project_name as prefix
  description = "Security group for Anvil metadata servers"
  vpc_id      = var.vpc_id
  tags        = local.common_tags

  ingress {
    protocol    = "icmp"
    from_port   = -1
    to_port     = -1
    cidr_blocks = [var.sec_ip_cidr]
  }
  # Anvil TCP Ports
  dynamic "ingress" {
    for_each = [22, 80, 111, 161, 443, 662, 2049, 2224, 4379, 7789, 8443, 9093, 9097, 9298, 9399, 20048, 20491, 20492, 21064, 50000, 51000, 53030] # Single ports from CFN
    content {
      protocol    = "tcp"
      from_port   = ingress.value
      to_port     = ingress.value
      cidr_blocks = [var.sec_ip_cidr]
    }
  }
  ingress { # TCP 4505-4506 from CFN
    protocol    = "tcp"
    from_port   = 4505
    to_port     = 4506
    cidr_blocks = [var.sec_ip_cidr]
  }
  ingress { # TCP 7789-7790 from CFN
    protocol    = "tcp"
    from_port   = 7789
    to_port     = 7790
    cidr_blocks = [var.sec_ip_cidr]
  }
  ingress { # TCP 9093-9094 from CFN
    protocol    = "tcp"
    from_port   = 9093
    to_port     = 9094
    cidr_blocks = [var.sec_ip_cidr]
  }
  ingress { # TCP 9298-9299 from CFN
    protocol    = "tcp"
    from_port   = 9298
    to_port     = 9299
    cidr_blocks = [var.sec_ip_cidr]
  }
  ingress { # TCP 41001-41256 from CFN
    protocol    = "tcp"
    from_port   = 41001
    to_port     = 41256
    cidr_blocks = [var.sec_ip_cidr]
  }
  ingress { # TCP 52000-52008 from CFN
    protocol    = "tcp"
    from_port   = 52000
    to_port     = 52008
    cidr_blocks = [var.sec_ip_cidr]
  }
  ingress { # TCP 53000-53008 from CFN
    protocol    = "tcp"
    from_port   = 53000
    to_port     = 53008
    cidr_blocks = [var.sec_ip_cidr]
  }

  # Anvil UDP Ports
  dynamic "ingress" {
    for_each = [111, 123, 161, 662, 4379, 5405, 20048] # From CFN
    content {
      protocol    = "udp"
      from_port   = ingress.value
      to_port     = ingress.value
      cidr_blocks = [var.sec_ip_cidr]
    }
  }
}

resource "aws_security_group" "dsx_sg" {
  count       = var.dsx_count > 0 ? 1 : 0
  name        = "${var.project_name}-DsxSG" # Using var.project_name as prefix
  description = "Security group for DSX data services nodes"
  vpc_id      = var.vpc_id
  tags        = local.common_tags

  ingress {
    protocol    = "icmp"
    from_port   = -1
    to_port     = -1
    cidr_blocks = [var.sec_ip_cidr]
  }
  # DSX TCP Ports
  dynamic "ingress" {
    for_each = [22, 111, 139, 161, 445, 662, 2049, 3049, 4379, 9093, 9292, 20048, 20491, 20492, 30048, 30049, 50000, 51000, 53030] # Single ports from CFN
    content {
      protocol    = "tcp"
      from_port   = ingress.value
      to_port     = ingress.value
      cidr_blocks = [var.sec_ip_cidr]
    }
  }
  ingress { # TCP 4505-4506 from CFN
    protocol    = "tcp"
    from_port   = 4505
    to_port     = 4506
    cidr_blocks = [var.sec_ip_cidr]
  }
  ingress { # TCP 9000-9009 from CFN
    protocol    = "tcp"
    from_port   = 9000
    to_port     = 9009
    cidr_blocks = [var.sec_ip_cidr]
  }
  ingress { # TCP 9095-9096 from CFN
    protocol    = "tcp"
    from_port   = 9095
    to_port     = 9096
    cidr_blocks = [var.sec_ip_cidr]
  }
  ingress { # TCP 9098-9099 from CFN
    protocol    = "tcp"
    from_port   = 9098
    to_port     = 9099
    cidr_blocks = [var.sec_ip_cidr]
  }
  ingress { # TCP 41001-41256 from CFN
    protocol    = "tcp"
    from_port   = 41001
    to_port     = 41256
    cidr_blocks = [var.sec_ip_cidr]
  }
  ingress { # TCP 52000-52008 from CFN
    protocol    = "tcp"
    from_port   = 52000
    to_port     = 52008
    cidr_blocks = [var.sec_ip_cidr]
  }
  ingress { # TCP 53000-53008 from CFN
    protocol    = "tcp"
    from_port   = 53000
    to_port     = 53008
    cidr_blocks = [var.sec_ip_cidr]
  }

  # DSX UDP Ports
  dynamic "ingress" {
    for_each = [111, 161, 662, 20048, 30048, 30049] # From CFN
    content {
      protocol    = "udp"
      from_port   = ingress.value
      to_port     = ingress.value
      cidr_blocks = [var.sec_ip_cidr]
    }
  }
}

# --- Anvil Standalone Resources ---
resource "aws_network_interface" "anvil_sa_ni" {
  count           = local.create_standalone_anvil ? 1 : 0
  subnet_id       = var.subnet_id
  security_groups = local.should_create_any_anvils ? [aws_security_group.anvil_data_sg[0].id] : []
  tags            = merge(local.common_tags, { Name = "${var.project_name}-Anvil-NI" })
  depends_on      = [aws_security_group.anvil_data_sg]
}
resource "aws_instance" "anvil" {
  count                  = local.create_standalone_anvil ? 1 : 0
  ami                    = var.ami
  instance_type          = local.anvil_instance_type_actual
  availability_zone      = var.availability_zone
  key_name               = local.provides_key_name ? var.key_name : null
  iam_instance_profile   = local.effective_instance_profile_ref
  user_data_base64       = local.anvil_sa_user_data_b64
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.anvil_sa_ni[0].id
  }
  root_block_device {
    volume_type = local.block_device_root_config.volume_type
    volume_size = local.block_device_root_config.volume_size
  }
  tags = merge(local.common_tags, { Name = "${var.project_name}-Anvil" })
  depends_on = [aws_iam_instance_profile.profile]
}
resource "aws_ebs_volume" "anvil_meta_vol" {
  count             = local.create_standalone_anvil ? 1 : 0
  availability_zone = var.availability_zone
  size              = var.anvil_meta_disk_size
  type              = var.anvil_meta_disk_type
  iops              = contains(["io1", "io2", "gp3"], var.anvil_meta_disk_type) ? var.anvil_meta_disk_iops : null
  throughput        = var.anvil_meta_disk_type == "gp3" ? var.anvil_meta_disk_throughput : null
  tags              = merge(local.common_tags, { Name = "${var.project_name}-Anvil-MetaVol" })
}
resource "aws_volume_attachment" "anvil_meta_vol_attach" {
  count       = local.create_standalone_anvil ? 1 : 0
  device_name = "/dev/sdb"
  instance_id = aws_instance.anvil[0].id
  volume_id   = aws_ebs_volume.anvil_meta_vol[0].id
}

# --- Anvil HA Resources ---
resource "aws_network_interface" "anvil1_ha_ni" {
  count           = local.create_ha_anvils ? 1 : 0
  subnet_id       = var.subnet_id
  security_groups = local.should_create_any_anvils ? [aws_security_group.anvil_data_sg[0].id] : []
  tags            = merge(local.common_tags, { Name = "${var.project_name}-Anvil1-NI" })
  depends_on      = [aws_security_group.anvil_data_sg]
}
resource "aws_instance" "anvil1" {
  count                  = local.create_ha_anvils ? 1 : 0
  ami                    = var.ami
  instance_type          = local.anvil_instance_type_actual
  availability_zone      = var.availability_zone
  key_name               = local.provides_key_name ? var.key_name : null
  iam_instance_profile   = local.effective_instance_profile_ref
  user_data_base64       = local.anvil1_ha_user_data_b64
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.anvil1_ha_ni[0].id
  }
  root_block_device {
    volume_type = local.block_device_root_config.volume_type
    volume_size = local.block_device_root_config.volume_size
  }
  tags = merge(local.common_tags, { Name = "${var.project_name}-Anvil1", Index = "0" })
  depends_on = [aws_iam_instance_profile.profile]
}
resource "aws_ebs_volume" "anvil1_meta_vol" {
  count             = local.create_ha_anvils ? 1 : 0
  availability_zone = var.availability_zone
  size              = var.anvil_meta_disk_size
  type              = var.anvil_meta_disk_type
  iops              = contains(["io1", "io2", "gp3"], var.anvil_meta_disk_type) ? var.anvil_meta_disk_iops : null
  throughput        = var.anvil_meta_disk_type == "gp3" ? var.anvil_meta_disk_throughput : null
  tags              = merge(local.common_tags, { Name = "${var.project_name}-Anvil1-MetaVol" })
}
resource "aws_volume_attachment" "anvil1_meta_vol_attach" {
  count       = local.create_ha_anvils ? 1 : 0
  device_name = "/dev/sdb"
  instance_id = aws_instance.anvil1[0].id
  volume_id   = aws_ebs_volume.anvil1_meta_vol[0].id
}

resource "aws_network_interface" "anvil2_ha_ni" {
  count             = local.create_ha_anvils ? 1 : 0
  subnet_id         = var.subnet_id
  security_groups   = local.should_create_any_anvils ? [aws_security_group.anvil_data_sg[0].id] : []
  private_ips_count = local.provides_cluster_ip ? 1 : 2
  tags              = merge(local.common_tags, { Name = "${var.project_name}-Anvil2-NI" })
  depends_on        = [aws_security_group.anvil_data_sg]
}
resource "aws_instance" "anvil2" {
  count                  = local.create_ha_anvils ? 1 : 0
  ami                    = var.ami
  instance_type          = local.anvil_instance_type_actual
  availability_zone      = var.availability_zone
  key_name               = local.provides_key_name ? var.key_name : null
  iam_instance_profile   = local.effective_instance_profile_ref
  user_data_base64       = local.anvil2_ha_user_data_b64
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.anvil2_ha_ni[0].id
  }
  root_block_device {
    volume_type = local.block_device_root_config.volume_type
    volume_size = local.block_device_root_config.volume_size
  }
  tags = merge(local.common_tags, { Name = "${var.project_name}-Anvil2", Index = "1" })
  depends_on = [aws_instance.anvil1, aws_iam_instance_profile.profile]
}
resource "aws_ebs_volume" "anvil2_meta_vol" {
  count             = local.create_ha_anvils ? 1 : 0
  availability_zone = length(aws_instance.anvil2) > 0 ? aws_instance.anvil2[0].availability_zone : var.availability_zone
  size              = var.anvil_meta_disk_size
  type              = var.anvil_meta_disk_type
  iops              = contains(["io1", "io2", "gp3"], var.anvil_meta_disk_type) ? var.anvil_meta_disk_iops : null
  throughput        = var.anvil_meta_disk_type == "gp3" ? var.anvil_meta_disk_throughput : null
  tags              = merge(local.common_tags, { Name = "${var.project_name}-Anvil2-MetaVol" })
}
resource "aws_volume_attachment" "anvil2_meta_vol_attach" {
  count       = local.create_ha_anvils ? 1 : 0
  device_name = "/dev/sdb"
  instance_id = aws_instance.anvil2[0].id
  volume_id   = aws_ebs_volume.anvil2_meta_vol[0].id
}

# --- DSX Data Services Node Resources ---
resource "aws_network_interface" "dsx_ni" {
  count           = var.dsx_count
  subnet_id       = var.subnet_id
  security_groups = var.dsx_count > 0 ? [aws_security_group.dsx_sg[0].id] : []
  tags            = merge(local.common_tags, { Name = "${var.project_name}-DSX${count.index + 1}-NI" })
  depends_on      = [aws_security_group.dsx_sg]
}
resource "aws_instance" "dsx" {
  count                  = var.dsx_count
  ami                    = var.ami
  instance_type          = local.dsx_instance_type_actual
  availability_zone      = var.availability_zone
  key_name               = local.provides_key_name ? var.key_name : null
  iam_instance_profile   = local.effective_instance_profile_ref
  user_data_base64 = base64encode(templatefile("${path.module}/templates/dsx.tftpl", merge(
    local.dsx_user_data_template_vars_base,
    { dsx_node_index_param = count.index + 1 }
  )))
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.dsx_ni[count.index].id
  }
  root_block_device {
    volume_type = local.block_device_root_config.volume_type
    volume_size = local.block_device_root_config.volume_size
  }
  source_dest_check = false
  tags = merge(local.common_tags, { Name = "${var.project_name}-DSX${count.index + 1}" })
  depends_on = [aws_iam_instance_profile.profile]
}
resource "aws_ebs_volume" "dsx_data_vol" {
  count             = var.dsx_count
  availability_zone = var.availability_zone
  size              = var.dsx_data_disk_size
  type              = var.dsx_data_disk_type
  iops              = contains(["io1", "io2", "gp3"], var.dsx_data_disk_type) ? var.dsx_data_disk_iops : null
  throughput        = var.dsx_data_disk_type == "gp3" ? var.dsx_data_disk_throughput : null
  tags              = merge(local.common_tags, { Name = "${var.project_name}-DSX${count.index + 1}-DataVol" })
}
resource "aws_volume_attachment" "dsx_data_vol_attach" {
  count       = var.dsx_count
  device_name = "/dev/sdb"
  instance_id = aws_instance.dsx[count.index].id
  volume_id   = aws_ebs_volume.dsx_data_vol[count.index].id
}
