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
  default     = "AWS-Sizing"
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

variable "storage_instance_count" {
  description = "Number of client instances"
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
  type	      = string
  default     = "raid-5"

  validation {
    condition	  = contains(["raid-0", "raid-5", "raid-6"], var.storage_raid_level)
    error_message = "RAID level must be one of: raid-0, raid-5, or raid-6"
  }
}
