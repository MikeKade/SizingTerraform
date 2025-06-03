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
- [Modules](#modules)

## Configuration

These variables apply to the overall deployment:

### Global Variables

* `region`: AWS region for all resources (Default: "us-west-2").
* `availability_zone`: AWS availability zone for resource placement (Default: "us-west-2b").
* `vpc_id`: (Required) VPC ID for all resources.
* `subnet_id`: (Required) Subnet ID for resources.
* `key_name`: (Required) SSH key pair name for instance access.
* `tags`: Common tags to apply to all resources (Default: `{}`).
* `project_name`: Project name used for tagging and resource naming (Default: "", validation ensures it's not empty).
* `ssh_keys_dir`: Directory containing SSH public keys for UserData scripts (Default: "./ssh_keys").
* `deploy_components`: List of components to deploy (e.g., `["clients", "storage", "hammerspace"]` or `["all"]`) (Default: `["all"]`).
* `instance_name_prefix`: Prefix for general resource naming (Default: "aws-sizing").

---

## Component Variables

### Client Variables

These variables configure the client instances and are prefixed with `clients_` in your `terraform.tfvars` file.

* **`clients_instance_count`**:
    * Description: Number of client instances.
    * Type: `number`
    * Default: `1`
* **`clients_ami`**:
    * Description: AMI for client instances.
    * Type: `string`
    * Required
* **`clients_instance_type`**:
    * Description: Instance type for clients.
    * Type: `string`
    * Default: `"m5n.8xlarge"`
* **`clients_boot_volume_size`**:
    * Description: Root volume size (GB) for clients.
    * Type: `number`
    * Default: `100`
* **`clients_boot_volume_type`**:
    * Description: Root volume type for clients.
    * Type: `string`
    * Default: `"gp2"`
* **`clients_ebs_count`**:
    * Description: Number of extra EBS volumes per client.
    * Type: `number`
    * Default: `1`
* **`clients_ebs_size`**:
    * Description: Size of each EBS volume (GB) for clients.
    * Type: `number`
    * Default: `1000`
* **`clients_ebs_type`**:
    * Description: Type of EBS volume for clients.
    * Type: `string`
    * Default: `"gp3"`
* **`clients_ebs_throughput`**:
    * Description: Throughput for gp3 EBS volumes for clients (MB/s).
    * Type: `number`
    * Default: `null`
* **`clients_ebs_iops`**:
    * Description: IOPS for gp3/io1/io2 EBS volumes for clients.
    * Type: `number`
    * Default: `null`
* **`clients_user_data`**:
    * Description: Path to user data script for clients.
    * Type: `string`
    * Default: `""`
* **`clients_target_user`**:
    * Description: Default system user for client EC2s.
    * Type: `string`
    * Default: `"ubuntu"`

---

### Storage Server Variables

These variables configure the storage server instances and are prefixed with `storage_` in your `terraform.tfvars` file.

* **`storage_instance_count`**:
    * Description: Number of storage instances.
    * Type: `number`
    * Default: `1`
* **`storage_ami`**:
    * Description: AMI for storage instances.
    * Type: `string`
    * Required
* **`storage_instance_type`**:
    * Description: Instance type for storage.
    * Type: `string`
    * Default: `"m5n.8xlarge"`
* **`storage_boot_volume_size`**:
    * Description: Root volume size (GB) for storage.
    * Type: `number`
    * Default: `100`
* **`storage_boot_volume_type`**:
    * Description: Root volume type for storage.
    * Type: `string`
    * Default: `"gp2"`
* **`storage_ebs_count`**:
    * Description: Number of extra EBS volumes per storage server.
    * Type: `number`
    * Default: `1`
* **`storage_ebs_size`**:
    * Description: Size of each EBS volume (GB) for storage.
    * Type: `number`
    * Default: `1000`
* **`storage_ebs_type`**:
    * Description: Type of EBS volume for storage.
    * Type: `string`
    * Default: `"gp3"`
* **`storage_ebs_throughput`**:
    * Description: Throughput for gp3 EBS volumes for storage (MB/s).
    * Type: `number`
    * Default: `null`
* **`storage_ebs_iops`**:
    * Description: IOPS for gp3/io1/io2 EBS volumes for storage.
    * Type: `number`
    * Default: `null`
* **`storage_user_data`**:
    * Description: Path to user data script for storage.
    * Type: `string`
    * Default: `""`
* **`storage_target_user`**:
    * Description: Default system user for storage EC2s.
    * Type: `string`
    * Default: `"ubuntu"`
* **`storage_raid_level`**:
    * Description: RAID level to configure (raid-0, raid-5, or raid-6).
    * Type: `string`
    * Default: `"raid-5"`
    * Validation: Must be one of: "raid-0", "raid-5", or "raid-6".

---

### Hammerspace Variables

These variables configure the Hammerspace deployment (Anvil and DSX nodes) and are prefixed with `hammerspace_` in your `terraform.tfvars` file.

* **`hammerspace_ami`**:
    * Description: AMI ID for Hammerspace instances.
    * Type: `string`
    * Default: `"ami-04add4f19d296b3e7"` (Example for us-west-2 CentOS 7)
* **`hammerspace_iam_admin_group_id`**:
    * Description: IAM admin group ID for SSH access (can be existing group name or blank to create new).
    * Type: `string`
    * Default: `""`
* **`hammerspace_anvil_count`**:
    * Description: Number of Anvil instances to deploy (0=none, 1=standalone, 2=HA).
    * Type: `number`
    * Default: `0`
    * Validation: Must be 0, 1, or 2.
* **`hammerspace_anvil_instance_type`**:
    * Description: Instance type for Anvil metadata server.
    * Type: `string`
    * Default: `"m5zn.12xlarge"`
* **`hammerspace_dsx_instance_type`**:
    * Description: Instance type for DSX nodes.
    * Type: `string`
    * Default: `"m5.xlarge"`
* **`hammerspace_dsx_count`**:
    * Description: Number of DSX instances.
    * Type: `number`
    * Default: `1`
* **`hammerspace_anvil_meta_disk_size`**:
    * Description: Metadata disk size in GB for Anvil.
    * Type: `number`
    * Default: `1000`
* **`hammerspace_anvil_meta_disk_type`**:
    * Description: Type of EBS volume for Anvil metadata disk (e.g., gp3, io2).
    * Type: `string`
    * Default: `"gp3"`
* **`hammerspace_anvil_meta_disk_throughput`**:
    * Description: Throughput for gp3 EBS volumes for the Anvil metadata disk (MiB/s).
    * Type: `number`
    * Default: `null` (Uses AWS default for gp3 unless specified)
* **`hammerspace_anvil_meta_disk_iops`**:
    * Description: IOPS for gp3/io1/io2 EBS volumes for the Anvil metadata disk.
    * Type: `number`
    * Default: `null` (Uses AWS default for gp3 unless specified)
* **`hammerspace_dsx_ebs_size`**:
    * Description: Size of each EBS Data volume per DSX node in GB.
    * Type: `number`
    * Default: `200`
* **`hammerspace_dsx_ebs_type`**:
    * Description: Type of each EBS Data volume for DSX (e.g., gp3, io2).
    * Type: `string`
    * Default: `"gp3"`
* **`hammerspace_dsx_ebs_iops`**:
    * Description: IOPS for each EBS Data volume for DSX.
    * Type: `number`
    * Default: `null`
* **`hammerspace_dsx_ebs_throughput`**:
    * Description: Throughput for each EBS Data volume for DSX (MiB/s).
    * Type: `number`
    * Default: `null`
* **`hammerspace_dsx_ebs_count`**:
    * Description: Number of data EBS volumes to attach to each DSX instance.
    * Type: `number`
    * Default: `1`
* **`hammerspace_dsx_add_vols`**:
    * Description: Add non-boot EBS volumes as Hammerspace storage volumes.
    * Type: `bool`
    * Default: `true`
* **`hammerspace_cluster_ip`**:
    * Description: Predefined Cluster IP address for Anvil (optional for new, required for DSX-only to existing).
    * Type: `string`
    * Default: `""`

---

## How to Use

1.  **Prerequisites**:
    * Install Terraform (see [Terraform website](https://www.terraform.io/downloads.html))
    * Configure AWS credentials (see [AWS provider documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication))
2.  **Initialize**: `terraform init`
3.  **Configure**: Create a `terraform.tfvars` file (or modify the existing one) to set your desired variable values.
    * Ensure `vpc_id`, `subnet_id`, and `key_name` are set correctly for your AWS environment.
    * Specify which components to deploy using `deploy_components = ["clients", "storage", "hammerspace"]` (or subset, or `["all"]`).
4.  **Plan**: `terraform plan`
5.  **Apply**: `terraform apply`

## Modules

This project is structured into the following modules:
* **clients**: Deploys client EC2 instances.
* **storage_servers**: Deploys storage server EC2 instances with configurable RAID and NFS exports.
* **hammerspace**: Deploys Hammerspace Anvil (metadata) and DSX (data) nodes.

Each module has its own set of variables for detailed configuration, which are fed by the root `variables.tf` and `terraform.tfvars` files.
