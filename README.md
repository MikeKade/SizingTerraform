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
- [Customizing Instance Setup via UserData Scripts](#customizing-instance-setup-via-userdata-scripts)
- [How to Use](#how-to-use)
- [Modules](#modules)

## Configuration

Configuration is managed through `terraform.tfvars` by setting values for the variables defined in `variables.tf`.

### Global Variables

These variables apply to the overall deployment:

* `region`: AWS region for all resources (Default: "us-west-2").
* `availability_zone`: AWS availability zone for resource placement (Default: "us-west-2b").
* `vpc_id`: (Required) VPC ID for all resources.
* `subnet_id`: (Required) Subnet ID for resources.
* `key_name`: (Required) SSH key pair name for instance access.
* `tags`: Common tags to apply to all resources (Default: `{}`).
* `project_name`: Project name used for tagging and resource naming (Default: "", validation ensures it's not empty).
* `ssh_keys_dir`: Directory containing SSH public keys for UserData scripts (Default: "./ssh_keys").
* `deploy_components`: List of components to deploy (e.g., `["clients", "storage", "hammerspace"]` or `["all"]`) (Default: `["all"]`). Valid items: "all", "clients", "storage", "hammerspace".
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
    * Description: Path to user data script for clients (e.g., `"./templates/client_config_ubuntu.sh"`).
    * Type: `string`
    * Default: `""`
* **`clients_target_user`**:
    * Description: Default system user for client EC2s (used by UserData script).
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
    * Description: Number of extra EBS volumes per storage server (used for RAID).
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
    * Description: Path to user data script for storage (e.g., `"./templates/storage_server_ubuntu.sh"`).
    * Type: `string`
    * Default: `""`
* **`storage_target_user`**:
    * Description: Default system user for storage EC2s (used by UserData script).
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
    * Validation: If `dsx_count > 0`, `dsx_ebs_count` must be at least 1 (This validation is inside the module).
* **`hammerspace_dsx_add_vols`**:
    * Description: Add non-boot EBS volumes as Hammerspace storage volumes.
    * Type: `bool`
    * Default: `true`
* **`hammerspace_cluster_ip`**:
    * Description: Predefined Cluster IP address for Anvil (optional for new, required for DSX-only to existing).
    * Type: `string`
    * Default: `""`

---

## Customizing Instance Setup via UserData Scripts

The client and storage server instances are configured at boot time using UserData scripts. You can customize these scripts to install additional software or perform other initial setup tasks.

The relevant script files are located in the `templates/` directory at the root of the project:
* `templates/client_config_ubuntu.sh` (used by the `clients` module if `var.clients_user_data` points to it)
* `templates/storage_server_ubuntu.sh` (used by the `storage_servers` module if `var.storage_user_data` points to it)

**How to Modify:**

1.  Open the respective `.sh` file (e.g., `templates/client_config_ubuntu.sh` or `templates/storage_server_ubuntu.sh`).
2.  Locate the section at the **top of the file** typically designated for package installations or custom commands.
    * For example, in `client_config_ubuntu.sh`, you'll see:
        ```bash
        # Update system and install required packages
        #
        # You can modify this based upon your needs

        sudo apt-get -y update
        sudo apt-get install -y pip git bc nfs-common screen net-tools fio # <- Add or change packages here
        ```
    * Similarly, `storage_server_ubuntu.sh` has a section:
        ```bash
        # Update and install required packages
        #
        # You can modify this based upon your needs

        sudo apt update
        sudo apt install -y net-tools nfs-common nfs-kernel-server sysstat mdadm # <- Add or change packages here
        ```
3.  **Important**: Only make your changes in this initial section, **ABOVE** the line that says:
    ```bash
    # WARNING!!
    # DO NOT MODIFY ANYTHING BELOW THIS LINE OR INSTANCES MAY NOT START CORRECTLY!
    # ----------------------------------------------------------------------------
    ```
    Modifying content below this warning line might interfere with the core functionality of the script (like RAID setup, NFS configuration, or SSH key injection).

4.  After saving your changes to the script(s), Terraform will use the updated UserData content the next time you create or recreate the relevant instances.

**Note on Hammerspace UserData**: The UserData for Hammerspace Anvil and DSX instances is generated from `.tftpl` templates within the `modules/hammerspace/templates/` directory. These are primarily for passing structured configuration data to the Hammerspace software and are generally not intended for arbitrary script execution in the same way as the client/storage server scripts. Customization of Anvil/DSX UserData should be done by modifying these `.tftpl` templates carefully if needed.

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
