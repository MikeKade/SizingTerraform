# Setup the provider

provider "aws" {
  region       = var.region
}

# Determine which components to deploy based on input list

locals {
  deploy_clients = contains(var.deploy_components, "all") || contains(var.deploy_components, "clients")
  deploy_storage = contains(var.deploy_components, "all") || contains(var.deploy_components, "storage")
}

# Deploy the clients module if requested

module "clients" {
  count  = local.deploy_clients ? 1 : 0
  source = "./modules/clients"

  # Global variables

  region            = var.region
  availability_zone = var.availability_zone
  vpc_id            = var.vpc_id
  subnet_id         = var.subnet_id
  key_name          = var.key_name
  tags              = var.tags
  project_name      = var.project_name
  ssh_keys_dir      = var.ssh_keys_dir
  name_prefix       = var.instance_name_prefix

  # Client-specific variables (mapping prefixed root to unprefixed module variables)

  instance_count    = var.clients_instance_count
  ami               = var.clients_ami
  instance_type     = var.clients_instance_type
  boot_volume_size  = var.clients_boot_volume_size
  boot_volume_type  = var.clients_boot_volume_type
  ebs_count         = var.clients_ebs_count
  ebs_size          = var.clients_ebs_size
  ebs_type          = var.clients_ebs_type
  ebs_throughput    = var.clients_ebs_throughput
  ebs_iops          = var.clients_ebs_iops
  user_data         = var.clients_user_data
  target_user       = var.clients_target_user
}

# Deploy the storage_servers module if requested

module "storage_servers" {
  count  = local.deploy_storage ? 1 : 0
  source = "./modules/storage_servers"

  # Global variables

  region            = var.region
  availability_zone = var.availability_zone
  vpc_id            = var.vpc_id
  subnet_id         = var.subnet_id
  key_name          = var.key_name
  tags              = var.tags
  project_name      = var.project_name
  ssh_keys_dir      = var.ssh_keys_dir
  name_prefix       = var.instance_name_prefix

  # Storage-specific variables (map root variables to unprefixed module variables)

  instance_count    = var.storage_instance_count
  ami               = var.storage_ami
  instance_type     = var.storage_instance_type
  boot_volume_size  = var.storage_boot_volume_size
  boot_volume_type  = var.storage_boot_volume_type
  raid_level	    = var.storage_raid_level
  ebs_count         = var.storage_ebs_count
  ebs_size          = var.storage_ebs_size
  ebs_type          = var.storage_ebs_type
  ebs_throughput    = var.storage_ebs_throughput
  ebs_iops          = var.storage_ebs_iops
  user_data         = var.storage_user_data
  target_user       = var.storage_target_user
}
