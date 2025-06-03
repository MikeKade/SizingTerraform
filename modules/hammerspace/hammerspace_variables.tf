variable "region" {
  description = "AWS region for deployment."
  type        = string
}

variable "availability_zone" {
  description = "Primary Availability Zone for Hammerspace resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where Hammerspace resources will be deployed."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for Hammerspace resources (Anvil and DSX nodes)."
  type        = string
}

variable "key_name" {
  description = "Name of an existing EC2 KeyPair for SSH access."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to all created resources."
  type        = map(string)
  default     = {}
}

variable "project_name" {
  description = "Name of the project, used in resource naming and tagging."
  type        = string
}

variable "name_prefix" {
  description = "Prefix for instance names and other named resources."
  type        = string
  default     = "hs"
}

variable "ami" {
  description = "AMI ID to use for Hammerspace Anvil and DSX instances."
  type        = string
}

variable "iam_admin_group_id" {
  description = "Name of an existing IAM Admin Group (optional). If blank and iam_user_access is enabled, a new group is created."
  type        = string
  default     = ""
}

variable "iam_user_access" {
  description = "Enable admin access for users in the specified IAM group ('Enable' or 'Disable')."
  type        = string
  default     = "Disable"
  validation {
    condition     = contains(["Enable", "Disable"], var.iam_user_access)
    error_message = "Allowed values for iam_user_access are 'Enable' or 'Disable'."
  }
}

variable "profile_id" {
  description = "Existing Instance Profile Name or ARN (optional). If blank, new IAM resources are created."
  type        = string
  default     = ""
}

variable "anvil_count" {
  description = "Number of Anvil instances to deploy. 0 = no Anvils; 1 = Standalone; 2+ = HA (2-node)."
  type        = number
  default     = 1 # Defaulting to 1 within the module if not overridden
}

variable "anvil_type" {
  description = "EC2 instance type for Anvil metadata servers (e.g., 'm5zn.12xlarge')."
  type        = string
}

variable "dsx_type" {
  description = "EC2 instance type for DSX data services nodes (e.g., 'm5.xlarge')."
  type        = string
}

variable "dsx_count" {
  description = "Number of DSX instances to create (0-8)."
  type        = number
  default     = 1 # Defaulting to 1 within the module if not overridden
}

variable "anvil_meta_disk_size" {
  description = "Anvil Metadata Disk Size in GB."
  type        = number
  default     = 1000
}

variable "anvil_meta_disk_type" {
  description = "Anvil Metadata Disk type (e.g., 'gp2', 'gp3', 'io1', 'io2')."
  type        = string
  default     = "gp3"
}

variable "anvil_meta_disk_iops" {
  description = "IOPS for Anvil metadata disk (required for io1/io2, optional for gp3)."
  type        = number
  default     = null
}

variable "anvil_meta_disk_throughput" {
  description = "Throughput in MiB/s for Anvil metadata disk (relevant for gp3)."
  type        = number
  default     = null
}

variable "dsx_data_disk_size" {
  description = "DSX Data Store Size per instance in GB."
  type        = number
  default     = 200
}

variable "dsx_data_disk_type" {
  description = "DSX Data Disk type (e.g., 'gp2', 'gp3', 'io1', 'io2')."
  type        = string
  default     = "gp3"
}

variable "dsx_data_disk_iops" {
  description = "IOPS for DSX data disk (required for io1/io2, optional for gp3)."
  type        = number
  default     = null
}

variable "dsx_data_disk_throughput" {
  description = "Throughput in MiB/s for DSX data disk (relevant for gp3)."
  type        = number
  default     = null
}

variable "dsx_add_vols" {
  description = "Add non-boot EBS volumes as Hammerspace storage volumes."
  type        = bool   # Changed to bool to match your root variable
  default     = true
}

variable "cluster_ip" {
  description = "Anvil Cluster IP (optional for new clusters; required if anvil_count = 0 and DSX nodes are added to existing external Anvil)."
  type        = string
  default     = ""
  validation {
    condition     = var.cluster_ip == "" || can(regex("^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", var.cluster_ip))
    error_message = "Cluster IP must be a valid IP address or empty."
  }
}

variable "sec_ip_cidr" {
  description = "Permitted IP/CIDR for Security Group Ingress. Use '0.0.0.0/0' for open access (not recommended for production)."
  type        = string
  default     = "0.0.0.0/0"
  validation {
    condition     = can(regex("^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/(?:3[0-2]|[12]?[0-9]?)$", var.sec_ip_cidr))
    error_message = "Security IP CIDR must be a valid CIDR block."
  }
}

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
# data "aws_region" "current" {} # This is implicitly available via provider or can be var.region
