#!/bin/bash

# Update system and install required packages
#
# You can modify this based upon your needs



# Create /tmp/anvil.yml with the specified configuration
cat > /tmp/anvil.yml << EOF
data_cluster_mgmt_ip: "${MGMT_IP}"
hsuser: admin 
password: "${ANVIL_ID}"
EOF

sudo apt-get -y update
sudo apt-get install -y pip git bc ansible screen net-tools jq

cat > /tmp/anvil.yml << EOF
data_cluster_mgmt_ip: "${MGMT_IP}"
hsuser: admin 
password: "${ANVIL_ID}"
EOF

echo '${STORAGE_INSTANCES}'

echo '${STORAGE_INSTANCES}' | jq -r '
  "storages:",
  map(
    "- name: \"" + .name + "\"\n" +
    "  nodeType: \"OTHER\"\n" +
    "  mgmtIpAddress:\n" +
    "    address: \"" + .private_ip + "\"\n" +
    "  _type: \"NODE\""
  )[]
' > /tmp/nodes.yml

# Upgrade all the installed packages

sudo apt-get -y upgrade

sudo git clone https://github.com/BeratUlualan/HS-Terraform.git /tmp/HS-Terraform
sudo ansible-playbook /tmp/HS-Terraform/hs-playbook.yml -e @/tmp/anvil.yml -e @/tmp/nodes.yml


# WARNING!!
# DO NOT MODIFY ANYTHING BELOW THIS LINE OR INSTANCES MAY NOT START CORRECTLY!
# ----------------------------------------------------------------------------

TARGET_USER="${TARGET_USER}"
TARGET_HOME="${TARGET_HOME}"
SSH_KEYS="${SSH_KEYS}"

# Build NFS mountpoint

sudo mkdir -p /mnt/nfs-test
sudo chmod 777 /mnt/nfs-test

# SSH Key Management

if [ -n "$${SSH_KEYS}" ]; then
    mkdir -p "$${TARGET_HOME}/.ssh"
    chmod 700 "$${TARGET_HOME}/.ssh"
    touch "$${TARGET_HOME}/.ssh/authorized_keys"
    
    # Process keys one by one to avoid multi-line issues

    echo "$${SSH_KEYS}" | while read -r key; do
        if [ -n "$${key}" ] && ! grep -qF "$${key}" "$${TARGET_HOME}/.ssh/authorized_keys"; then
            echo "$${key}" >> "$${TARGET_HOME}/.ssh/authorized_keys"
        fi
    done

    chmod 600 "$${TARGET_HOME}/.ssh/authorized_keys"
    chown -R "$${TARGET_USER}:$${TARGET_USER}" "$${TARGET_HOME}/.ssh"
fi

# Reboot
#sudo reboot
