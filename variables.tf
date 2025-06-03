# Global variables (NO prefix)

variable "region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-west-2"
}

variable "availability_zone" {
  description = "AWS availability zone"
  type        = string
  default     = "us-west-2b"
}

variable "vpc_id" {
  description = "VPC ID for all resources"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for resources"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = ""
  validation {
    condition     = var.project_name != ""
    error_message = "Project must have a name"
  }
}

variable "ssh_keys_dir" {
  description = "Directory containing SSH public keys"
  type        = string
  default     = "./ssh_keys"
}

variable "deploy_components" {
  description = "Components to deploy (clients, storage, etc)"
  type        = list(string)
  default     = ["all"]
}

variable "instance_name_prefix" {
  description = "Prefix for resource naming"
  type        = string
  default     = "aws-sizing"
}

# CLIENT-SPECIFIC VARIABLES (WITH clients_ PREFIX)
# ... (client variables remain unchanged) ...
variable "clients_instance_count" {
  description = "Number of client instances"
  type        = number
  default     = 1
}

variable "clients_ami" {
  description = "AMI for client instances"
  type        = string
}

variable "clients_instance_type" {
  description = "Instance type for clients"
  type        = string
  default     = "m5n.8xlarge"
}

variable "clients_boot_volume_size" {
  description = "Root volume size (GB) for clients"
  type        = number
  default     = 100
}

variable "clients_boot_volume_type" {
  description = "Root volume type for clients"
  type        = string
  default     = "gp2"
}

variable "clients_ebs_count" {
  description = "Number of extra EBS volumes per client"
  type        = number
  default     = 1
}

variable "clients_ebs_size" {
  description = "Size of each EBS volume (GB) for clients"
  type        = number
  default     = 1000
}

variable "clients_ebs_type" {
  description = "Type of EBS volume for clients"
  type        = string
  default     = "gp3"
}

variable "clients_ebs_throughput" {
  description = "Throughput for gp3 EBS volumes for clients (MB/s)"
  type        = number
  default     = null
}

variable "clients_ebs_iops" {
  description = "IOPS for gp3/io1/io2 EBS volumes for clients"
  type        = number
  default     = null
}

variable "clients_user_data" {
  description = "Path to user data script for clients"
  type        = string
  default     = ""
}

variable "clients_target_user" {
  description = "Default system user for client EC2s"
  type        = string
  default     = "ubuntu"
}

# STORAGE-SPECIFIC VARIABLES (WITH storage_ PREFIX)
# ... (storage variables remain unchanged) ...
variable "storage_instance_count" {
  description = "Number of client instances" # Note: description says client, might be storage
  type        = number
  default     = 1
}

variable "storage_ami" {
  description = "AMI for storage instances"
  type        = string
}

variable "storage_instance_type" {
  description = "Instance type for storage"
  type        = string
  default     = "m5n.8xlarge"
}

variable "storage_boot_volume_size" {
  description = "Root volume size (GB) for storage"
  type        = number
  default     = 100
}

variable "storage_boot_volume_type" {
  description = "Root volume type for storage"
  type        = string
  default     = "gp2"
}

variable "storage_ebs_count" {
  description = "Number of extra EBS volumes per storage"
  type        = number
  default     = 1
}

variable "storage_ebs_size" {
  description = "Size of each EBS volume (GB) for storage"
  type        = number
  default     = 1000
}

variable "storage_ebs_type" {
  description = "Type of EBS volume for storage"
  type        = string
  default     = "gp3"
}

variable "storage_ebs_throughput" {
  description = "Throughput for gp3 EBS volumes for storage (MB/s)"
  type        = number
  default     = null
}

variable "storage_ebs_iops" {
  description = "IOPS for gp3/io1/io2 EBS volumes for storage"
  type        = number
  default     = null
}

variable "storage_user_data" {
  description = "Path to user data script for storage"
  type        = string
  default     = ""
}

variable "storage_target_user" {
  description = "Default system user for storage EC2s"
  type        = string
  default     = "ubuntu"
}

variable "storage_raid_level" {
  description = "RAID level to configure (raid-0, raid-5, or raid-6)"
  type        = string
  default     = "raid-5"

  validation {
    condition     = contains(["raid-0", "raid-5", "raid-6"], var.storage_raid_level)
    error_message = "RAID level must be one of: raid-0, raid-5, or raid-6"
  }
}

# Hammerspace-specific variables

variable "hammerspace_ami" {
  description = "AMI ID for Hammerspace instances"
  type        = string
  default     = "ami-04add4f19d296b3e7"
}

variable "hammerspace_iam_admin_group_id" {
  description = "IAM admin group ID for SSH access (can be existing group name or blank to create new)"
  type        = string
  default     = ""
}

variable "hammerspace_anvil_count" {
  description = "Number of Anvil instances to deploy (0=none, 1=standalone, 2=HA)"
  type        = number
  default     = 0
  validation {
    condition     = var.hammerspace_anvil_count >= 0 && var.hammerspace_anvil_count <= 2
    error_message = "anvil count must be 0, 1 (standalone), or 2 (HA)"
  }
}

variable "hammerspace_anvil_instance_type" {
  description = "Instance type for Anvil metadata server"
  type        = string
  default     = "m5zn.12xlarge"
}

variable "hammerspace_dsx_instance_type" {
  description = "Instance type for DSX nodes"
  type        = string
  default     = "m5.xlarge"
}

variable "hammerspace_dsx_count" {
  description = "Number of DSX instances"
  type        = number
  default     = 1
}

variable "hammerspace_anvil_meta_disk_size" {
  description = "Metadata disk size in GB for Anvil"
  type        = number
  default     = 1000
}

variable "hammerspace_anvil_meta_disk_type" {
  description = "Type of EBS volume for Anvil metadata disk (e.g., gp3, io2)"
  type        = string
  default     = "gp3"
}

variable "hammerspace_anvil_meta_disk_throughput" {
  description = "Throughput for gp3 EBS volumes for the Anvil metadata disk (MiB/s)"
  type        = number
  default     = null
}

variable "hammerspace_anvil_meta_disk_iops" {
  description = "IOPS for gp3/io1/io2 EBS volumes for the Anvil metadata disk"
  type        = number
  default     = null
}

variable "hammerspace_dsx_ebs_size" { # RENAMED from hammerspace_dsx_data_disk_size
  description = "Size of each EBS Data volume per DSX node in GB"
  type        = number
  default     = 200
}

variable "hammerspace_dsx_ebs_type" { # ADDED for consistency, if you want to control from root
  description = "Type of each EBS Data volume for DSX (e.g., gp3, io2)"
  type        = string
  default     = "gp3" # Or remove default if module default is preferred
}

variable "hammerspace_dsx_ebs_iops" { # ADDED for consistency
  description = "IOPS for each EBS Data volume for DSX"
  type        = number
  default     = null
}

variable "hammerspace_dsx_ebs_throughput" { # ADDED for consistency
  description = "Throughput for each EBS Data volume for DSX (MiB/s)"
  type        = number
  default     = null
}

variable "hammerspace_dsx_ebs_count" { # RENAMED from hammerspace_dsx_data_volumes_per_instance
  description = "Number of data EBS volumes to attach to each DSX instance."
  type        = number
  default     = 1
}

variable "hammerspace_dsx_add_vols" {
  description = "Add non-boot EBS volumes as Hammerspace storage volumes"
  type        = bool
  default     = true
}

variable "hammerspace_cluster_ip" {
  description = "Predefined Cluster IP address for Anvil (optional for new, required for DSX-only to existing)"
  type        = string
  default     = ""
}
