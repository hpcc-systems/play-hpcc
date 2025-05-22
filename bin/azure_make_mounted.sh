#!/usr/bin/env bash

FSTAB=/etc/fstab

# Display the block devices filtered for "sd" in their names
echo "Listing storage devices:"
lsblk -o NAME,HCTL,SIZE,MOUNTPOINT | grep -i "sd"

# Prompt the user for input
read -p "Enter the device name for which we will partition and create a mountpoint: " DEVICE_NAME
read -p "Enter the (bare) name of the mountpoint's directory': " MNT_DIRNAME

# Create partition and format it
sudo parted /dev/${DEVICE_NAME} --script mklabel gpt mkpart xfspart xfs 0% 100%
sudo mkfs.xfs /dev/${DEVICE_NAME}1
sudo partprobe /dev/${DEVICE_NAME}1

# Make the mountpoint directory
sudo mkdir -p /${MNT_DIRNAME}
sudo mount /dev/${DEVICE_NAME}1 /${MNT_DIRNAME}

# Register the partition as something that needs remounting after boot
UUID=$(sudo -i blkid | grep "${DEVICE_NAME}1:" | sed -n 's/.* UUID="\([^"]*\)".*/\1/p')
sudo echo "" >> ${FSTAB}
# Note embedded tabs in next line
sudo echo "UUID=${UUID}	/${MNT_DIRNAME}	xfs	defaults,nofail	1	2 >> ${FSTAB}"

echo "Done"
