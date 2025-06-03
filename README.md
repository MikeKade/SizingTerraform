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
    * Type: `number
    