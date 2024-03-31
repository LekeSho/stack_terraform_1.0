#!/bin/bash 
#Update the system packages
sudo yum update -y
# install LAMP stack using Amazon Linux extras
sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
sudo yum install -y httpd mariadb-server
# Start and enable Apache HTTP Server
sudo systemctl start httpd
sudo systemctl enable httpd
# Check if Apache HTTP server is enabled
sudo systemctl is-enabled httpd
#check test page
sudo usermod -a -G apache ec2-user
#checking the groups to verify addition of 'apache'
groups
#Set permissions and ownership for /var/www/ directory
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;

mkdir -p ${MOUNT_POINT}
#Create EFS MountPoint(Added this modification)
echo ${EFS_DNS_NAME2}:/ ${MOUNT_POINT} nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,_netdev 0 0 >> /etc/fstab
mount -a -t nfs4

# #Attaching EBS#######################################
  #EBS VOLUMES
EBS_DEVICES="/dev/sdb /dev/sdc /dev/sdd /dev/sde /dev/sdg"

#Partitioning Disks
for device in $${EBS_DEVICES}; do
    echo "Partitioning $${device}..."
    echo -e "\np\nn\np\n1\n2048\n16777215\np\nw" | fdisk $${device}

    #checking if newly partitioned disk exists before creating physical volume
    if lsblk $${device}1; then
        pvcreate $${device}1
    else
        echo "Partition $${device}1 does not exist. Retrying..."
        sleep 5
    fi
done
echo "Disk Partitioning Complete!"


#creating volume group with Newly partitioned volumes
pv_part_string="/dev/sdb1 /dev/sdc1 /dev/sdd1 /dev/sde1 /dev/sdg1"

vgcreate stack_vg $${pv_part_string}
echo "Volume group successfully created!"

#viewing newly created volume group
vgs

#Creating logical volumes
lv_names="u01 u02 u03 u04 backup"

for name in $${lv_names}; do

    echo "Creating Logical volume Lv_$${name}!"

    lvcreate -L 5G -n Lv_$${name} stack_vg
done

echo "Logical volumes successfully created!"

#formatting Logical volume
volumes="Lv_u01 Lv_u02 Lv_u03 Lv_u04 Lv_backup"
for disk in $${volumes}; do
    echo "Formatting /dev/stack_vg/$${disk} with ext4" 
    mkfs.ext4 "/dev/stack_vg/$${disk}"
    echo "$${disk} Successfully formatted"
done

echo "Logical volume formatting successfully completed!"

# Convert space-separated strings to arrays
volume=("Lv_u01" "Lv_u02" "Lv_u03" "Lv_u04" "Lv_backup")
mount=("/u01" "/u02" "/u03" "/u04" "/backup")

# Ensure both arrays have the same length
if [ $${#volume[@]} -ne $${#mount[@]} ]; then
    echo "Volumes and mounts count do not match."
    exit 1
fi

# Iterate over arrays by index
for i in "$${!volume[@]}"; do
    disk=$${volume[$${i}]}
    mount_p=$${mount[$${i}]}
    
    # Create the mount point
    mkdir -p "$${mount_p}"
    
    # Mount the logical volume to the mount point
    echo "Mounting /dev/stack_vg/$${disk} to $${mount_p}"
    mount "/dev/stack_vg/$${disk}" "$${mount_p}"

    # Make the mount persistent across boots by adding it to /etc/fstab
    echo "/dev/stack_vg/$${disk} $${mount_p} ext4 defaults 0 2" >> /etc/fstab
done


echo "Mount points created and Disks successfully mounted!"

#Install addition PHP stuff and restarting services
sudo yum install php-mbstring -y
sudo systemctl restart httpd
sudo systemctl restart php-fpm


#Installing git

cd ${MOUNT_POINT} 
sudo yum install git -y
chmod -R 755 ${MOUNT_POINT}

if [ sudo -d "MY_STACK_BLOG" ]; then
    echo "MY_STACK_BLOG exists, skipping ....."
else
    git clone ${GIT_REPO}
    cp -r MY_STACK_BLOG/* ${MOUNT_POINT}

fi

WP_CONFIG=${MOUNT_POINT}/wp-config.php

NEW_RDS_INSTANCE=$(echo "${RDS_INSTANCE}" |sed 's/':3306'//g')

#NEW_RDS_INSTANCE=$(echo "${RDS_INSTANCE}" | sed 's/:3306//g')



#Update wordpress config with db details
sudo sed -i "s/'database_name_here'/'${DB_NAME}'/g" ${WP_CONFIG}
sudo sed -i "s/'username_here'/'${DB_USER}'/g" ${WP_CONFIG}
sudo sed -i "s/'password_here'/'${DB_PASSWORD}'/g" ${WP_CONFIG}
sudo sed -i "s/'rds_instance'/'$${NEW_RDS_INSTANCE}'/g" ${WP_CONFIG}
sudo sed -i '151s/None/All/' /etc/httpd/conf/httpd.conf

#restart apache http server and enable services
sudo systemctl restart httpd
sudo systemctl enable httpd && sudo systemctl enable mariadb
#sudo systemctl status of MySQL and apache HTTP server
sudo systemctl status mariadb
sudo systemctl status httpd

# Restart Apache to make sure all changes take effect
sudo systemctl restart httpd


mysql -h "$${NEW_RDS_INSTANCE}" -u "${DB_USER}" -p"${DB_PASSWORD}" "${DB_NAME}" <<EOF
UPDATE wp_options SET option_value = '${load_balancer_dns2}' WHERE option_value LIKE '%44.212.89.12';
EOF


