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
- [How to Use](#how-to-use)
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

## How to Use

1.  **Prerequisites**:
    * Install Terraform.
    * Install and configure the AWS CLI. Your credentials should be stored in `~/.aws/credentials`.
2.  **Configure Authentication**: Open `main.tf` and set the `profile` argument in the `provider "aws"` block to match the profile name in your credentials file.
    ```terraform
    provider "aws" {
      region  = var.region
      profile = "your-profile-name"
    }
    ```
3.  **Initialize**: `terraform init`
4.  **Configure**: Create a `terraform.tfvars` file to set your desired variables. At a minimum, you must provide `project_name`, `vpc_id`, `subnet_id`, `key_name`, and the required `*_ami` variables.
5.  **Plan**: `terraform plan`
6.  **Apply**: `terraform apply`

---

## Outputs

After a successful `apply`, Terraform will provide the following outputs. Sensitive values will be redacted and can be viewed with `terraform output <output_name>`.

* `client_instances`: A list of non-sensitive details for each client instance (ID, IP, Name).
* `client_ebs_volumes`: **(Sensitive)** A list of sensitive EBS volume details for each client.
* `storage_instances`: A list of non-sensitive details for each storage instance.
* `storage_ebs_volumes`: **(Sensitive)** A list of sensitive EBS volume details for each storage server.
* `hammerspace_anvil`: **(Sensitive)** A list of detailed information for the deployed Anvil nodes.
* `hammerspace_dsx`: A list of detailed information for the deployed DSX nodes.
* `hammerspace_mgmt_url`: The URL to access the Hammerspace management interface.
* `dsx_userdata_rendered`: **(Sensitive)** The rendered UserData configuration for the first DSX node, useful for debugging.

---
## Modules

This project is structured into the following modules:
* **clients**: Deploys client EC2 instances.
* **storage_servers**: Deploys storage server EC2 instances with configurable RAID and NFS exports.
* **hammerspace**: Deploys Hammerspace Anvil (metadata) and DSX (data) nodes.

---
## Customizing Instance Setup via UserData Scripts

The `client` and `storage_server` instances are configured at boot time using the scripts located in the `templates/` directory. You can customize these scripts to install additional software or perform other setup tasks. See the comments at the top of each script for guidance.
