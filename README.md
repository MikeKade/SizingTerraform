# SizingTerraform
Terraform templates to create clients, storage, and Hammerspace for AWS sizing.

This project uses Terraform to provision resources on AWS. The deployment is modular, allowing you to deploy client machines, storage servers, and a Hammerspace environment either together or independently.

## Table of Contents
- [Configuration](#configuration)
  - [Global Variables](#global-variables)
- [Component Variables](#component-variables)
  - [Client Variables](#client-variables)
  - [Storage Server Variables](#storage-server-variables)
  - [Hammerspace Variables](#hammerspace-variables)
- [Required IAM Permissions for Custom Instance Profile](#required-iam-permissions-for-custom-instance-profile)
- [How to Use](#how-to-use)
- [Important Note on Placement Group Deletion](#important-note-on-placement-group-deletion)
- [Outputs](#outputs)
- [Modules](#modules)
- [Customizing Instance Setup via UserData Scripts](#customizing-instance-setup-via-userdata-scripts)


## Configuration

Configuration is managed through `terraform.tfvars` by setting values for the variables defined in `variables.tf`.

### Global Variables

These variables apply to the overall deployment:

* `region`: AWS region for all resources (Default: "us-west-2").
* `availability_zone`: AWS availability zone for resource placement (Default: "us-west-2b").
* `vpc_id`: (Required) VPC ID for all resources.
* `subnet_id`: (Required) Subnet ID for resources.
* `key_name`: (Required) SSH key pair name for instance access. This key is still required by AWS for the instance launch, even if not used for login.
* `tags`: Common tags to apply to all resources (Default: `{}`).
* `project_name`: (Required) Project name used for tagging and resource naming.
* `ssh_keys_dir`: A local directory where you can place multiple public SSH key files (e.g., `user1.pub`, `user2.pub`). The startup script will automatically add these keys to the `authorized_keys` file on all servers. This allows users to `ssh` into the instances with their own personal private keys instead of sharing the single EC2 `.pem` file. (Default: `"./ssh_keys"`).
* `deploy_components`: List of components to deploy (e.g., `["clients", "storage", "hammerspace"]` or `["all"]`) (Default: `["all"]`).
* `placement_group_name`: (Optional) The name of the placement group to create and launch instances into. If left blank, no placement group is used.
* `placement_group_strategy`: The strategy for the placement group: `cluster`, `spread`, or `partition` (Default: `cluster`).

---

## Component Variables

### Client Variables

These variables configure the client instances and are prefixed with `clients_` in your `terraform.tfvars` file.

* `clients_instance_count`: Number of client instances (Default: `1`).
* `clients_ami`: (Required) AMI for client instances.
* `clients_instance_type`: Instance type for clients (Default: `"m5n.8xlarge"`).
* `clients_boot_volume_size`: Root volume size (GB) (Default: `100`).
* `clients_boot_volume_type`: Root volume type (Default: `"gp2"`).
* `clients_ebs_count`: Number of extra EBS volumes per client (Default: `1`).
* `clients_ebs_size`: Size of each EBS volume (GB) (Default: `1000`).
* `clients_ebs_type`: Type of EBS volume (Default: `"gp3"`).
* `clients_ebs_throughput`: Throughput for gp3 EBS volumes (MB/s).
* `clients_ebs_iops`: IOPS for gp3/io1/io2 EBS volumes.
* `clients_user_data`: Path to user data script for clients.
* `clients_target_user`: Default system user for client EC2s (Default: `"ubuntu"`).

---

### Storage Server Variables

These variables configure the storage server instances and are prefixed with `storage_` in your `terraform.tfvars` file.

* `storage_instance_count`: Number of storage instances (Default: `1`).
* `storage_ami`: (Required) AMI for storage instances.
* `storage_instance_type`: Instance type for storage (Default: `"m5n.8xlarge"`).
* `storage_boot_volume_size`: Root volume size (GB) (Default: `100`).
* `storage_boot_volume_type`: Root volume type (Default: `"gp2"`).
* `storage_ebs_count`: Number of extra EBS volumes per server for RAID (Default: `1`).
* `storage_ebs_size`: Size of each EBS volume (GB) (Default: `1000`).
* `storage_ebs_type`: Type of EBS volume (Default: `"gp3"`).
* `storage_ebs_throughput`: Throughput for gp3 EBS volumes (MB/s).
* `storage_ebs_iops`: IOPS for gp3/io1/io2 EBS volumes.
* `storage_user_data`: Path to user data script for storage.
* `storage_target_user`: Default system user for storage EC2s (Default: `"ubuntu"`).
* `storage_raid_level`: RAID level to configure: `raid-0`, `raid-5`, or `raid-6` (Default: `"raid-5"`).

---

### Hammerspace Variables

These variables configure the Hammerspace deployment and are prefixed with `hammerspace_` in `terraform.tfvars`.

* **`hammerspace_profile_id`**: Controls IAM Role creation.
    * **For users with restricted IAM permissions**: An admin must pre-create an IAM Instance Profile and provide its name here. Terraform will use the existing profile.
    * **For admin users**: Leave this variable as `""` (blank). Terraform will automatically create the necessary IAM Role and Instance Profile.
* **`hammerspace_anvil_security_group_id`**: (Optional) The ID of a pre-existing security group to attach to the Anvil nodes. If left blank, the module will create and configure a new security group. This is useful for debugging or integrating with existing network rules.
* **`hammerspace_dsx_security_group_id`**: (Optional) The ID of a pre-existing security group to attach to the DSX nodes. If left blank, the module will create and configure a new security group.
* `hammerspace_ami`: AMI ID for Hammerspace instances (Default: example for CentOS 7).
* `hammerspace_iam_admin_group_id`: IAM admin group for SSH access.
* `hammerspace_anvil_count`: Number of Anvil instances (0=none, 1=standalone, 2=HA) (Default: `0`).
* `hammerspace_anvil_instance_type`: Instance type for Anvil (Default: `"m5zn.12xlarge"`).
* `hammerspace_dsx_instance_type`: Instance type for DSX nodes (Default: `"m5.xlarge"`).
* `hammerspace_dsx_count`: Number of DSX instances (Default: `1`).
* `hammerspace_anvil_meta_disk_size`: Metadata disk size in GB for Anvil (Default: `1000`).
* `hammerspace_anvil_meta_disk_type`: EBS volume type for Anvil metadata disk (Default: `"gp3"`).
* `hammerspace_anvil_meta_disk_throughput`: Throughput for Anvil metadata disk.
* `hammerspace_anvil_meta_disk_iops`: IOPS for Anvil metadata disk.
* `hammerspace_dsx_ebs_size`: Size of each EBS Data volume per DSX node (Default: `200`).
* `hammerspace_dsx_ebs_type`: Type of each EBS Data volume for DSX (Default: `"gp3"`).
* `hammerspace_dsx_ebs_iops`: IOPS for each EBS Data volume for DSX.
* `hammerspace_dsx_ebs_throughput`: Throughput for each EBS Data volume for DSX.
* `hammerspace_dsx_ebs_count`: Number of data EBS volumes per DSX instance (Default: `1`).
* `hammerspace_dsx_add_vols`: Add non-boot EBS volumes as Hammerspace storage (Default: `true`).

---

## Required IAM Permissions for Custom Instance Profile
If you are using the `hammerspace_profile_id` variable to provide a pre-existing IAM Instance Profile, the associated IAM Role must have a policy attached with the following permissions.

**Summary for AWS Administrators:**
1.  Create an IAM Policy with the JSON below.
2.  Create an IAM Role for the EC2 Service (`ec2.amazonaws.com`).
3.  Attach the new policy to the role.
4.  Create an Instance Profile and attach the role to it.
5.  Provide the name of the **Instance Profile** to the user running Terraform.

**Required IAM Policy JSON:**
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "SSHKeyAccess",
            "Effect": "Allow",
            "Action": [
                "iam:ListSSHPublicKeys",
                "iam:GetSSHPublicKey",
                "iam:GetGroup"
            ],
            "Resource": "arn:aws:iam::*:user/*"
        },
        {
            "Sid": "HAInstanceDiscovery",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceAttribute",
                "ec2:DescribeTags"
            ],
            "Resource": "*"
        },
        {
            "Sid": "HAFloatingIP",
            "Effect": "Allow",
            "Action": [
                "ec2:AssignPrivateIpAddresses",
                "ec2:UnassignPrivateIpAddresses"
            ],
            "Resource": "*"
        },
        {
            "Sid": "MarketplaceMetering",
            "Effect": "Allow",
            "Action": "aws-marketplace:MeterUsage",
            "Resource": "*"
        }
    ]
}
