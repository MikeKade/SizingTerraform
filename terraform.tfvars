# Which components to deploy

deploy_components                        = ["hammerspace"]

# Global variables

project_name				 = "AWSSizing"
key_name     				 = "Kade"
vpc_id       				 = "vpc-e3bff585"
subnet_id    				 = "subnet-085aa3041039c047f"

tags = {
  Owner = "Mike Kade"
  Project = "AWS-Sizing"
}

# Client specific variables (clients_ prefix)

clients_instance_count                   = 2
clients_ami              		 = "ami-075686beab831bb7f"
clients_instance_type    		 = "m5n.8xlarge"
clients_boot_volume_size 		 = 100
clients_boot_volume_type 		 = "gp2"
clients_ebs_count        		 = 0
clients_ebs_size         		 = 1000
clients_ebs_type         		 = "gp3"
clients_ebs_iops         		 = 9000
clients_ebs_throughput   		 = 1000
clients_user_data        		 = "./templates/client_config_ubuntu.sh"
clients_target_user      		 = "ubuntu"

# Storage specific variables (storage_ prefix)

storage_instance_count       	         = 2
storage_ami              		 = "ami-075686beab831bb7f"
storage_instance_type    		 = "m5n.8xlarge"
storage_boot_volume_size 		 = 100
storage_boot_volume_type 		 = "gp2"
storage_raid_level       		 = "raid-6"
storage_ebs_count        		 = 6
storage_ebs_size         		 = 1000
storage_ebs_type         		 = "gp3"
storage_ebs_iops         		 = 9000
storage_ebs_throughput   		 = 1000
storage_user_data        		 = "./templates/storage_server_ubuntu.sh"
storage_target_user      		 = "ubuntu"

# Hammerspace (Anvil, DSX) specific variables

hammerspace_ami				 = "ami-02300b13d054bff31"
hammerspace_cluster_ip           	 = ""

# Comment the following if creating a new Profile ID

hammerspace_profile_id			 = "Hammerspace"
hammerspace_anvil_count		 	 = 1
hammerspace_anvil_instance_type  	 = "m5n.8xlarge"
hammerspace_anvil_meta_disk_size 	 = 1000
hammerspace_anvil_meta_disk_type 	 = "gp3"
hammerspace_anvil_meta_disk_iops 	 = 9000
hammerspace_anvil_meta_disk_throughput 	 = 1000

hammerspace_dsx_count                    = 0
hammerspace_dsx_instance_type    	 = "m5n.8xlarge"
hammerspace_dsx_ebs_count		 = 1
hammerspace_dsx_ebs_size   	 	 = 500
hammerspace_dsx_ebs_type		 = "gp3"
hammerspace_dsx_ebs_iops		 = 6000
hammerspace_dsx_ebs_throughput		 = 1000


