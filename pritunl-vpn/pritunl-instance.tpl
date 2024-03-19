#!/bin/bash

#Associate EIP - This maintains the same IP for firewalls, vpn clients, etc.
sudo AWS_ACCESS_KEY_ID=${access_key} AWS_SECRET_ACCESS_KEY=${secret_key} aws ec2 associate-address --instance-id $(curl http://169.254.169.254/latest/meta-data/instance-id) --allocation-id ${eip_id} --allow-reassociation --region ${region}

#Install and setup Pritunl and MongoDB
echo "Install and setup Pritunl and MongoDB..."


sudo tee /etc/yum.repos.d/mongodb-org-4.0.repo << EOF
[mongodb-org-4.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2/mongodb-org/${mongodb_version}/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-${mongodb_version}.asc
EOF

sudo tee /etc/yum.repos.d/pritunl.repo << EOF
[pritunl]
name=Pritunl Repository
baseurl=https://repo.pritunl.com/stable/yum/amazonlinux/2/
gpgcheck=1
enabled=1
EOF

sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 7568D9BB55FF9E5287D586017AE645C0CF8E292A
gpg --armor --export 7568D9BB55FF9E5287D586017AE645C0CF8E292A > key.tmp; sudo rpm --import key.tmp; rm -f key.tmp
sudo yum -y install pritunl mongodb-org
sudo systemctl start mongod pritunl
sudo systemctl enable mongod pritunl

#Stop Pritunl
sudo service pritunl stop
sleep 10

#Set path for MongoDB:
echo "Set path for MongoDB..."
sudo pritunl set-mongodb mongodb://localhost:27017/pritunl


#Create Backup Script:
echo "Create Backup Script..."
mkdir pritunl
cd /pritunl
touch pritunl-backup.sh
chmod 755 pritunl-backup.sh
echo "#!/bin/bash" >> pritunl-backup.sh
echo "#The following command will create a dump/ dir." >> pritunl-backup.sh
echo "sudo mongodump" >> pritunl-backup.sh
echo "aws s3 cp --recursive /pritunl/dump s3://${pritunlbucket}/pritunl/dump/" >> pritunl-backup.sh
echo "sudo aws s3 cp /var/lib/pritunl/pritunl.uuid s3://${pritunlbucket}/pritunl/pritunl.uuid" >> pritunl-backup.sh
echo "exit 0" >> pritunl-backup.sh
sleep 10

#Create Restore Script:
echo "Create Restore Script..."
touch pritunl-restore.sh
chmod 755 pritunl-restore.sh
echo "#!/bin/bash" >> pritunl-restore.sh
echo "sudo service pritunl stop" >> pritunl-restore.sh
echo "sudo aws s3 cp --recursive s3://${pritunlbucket}/pritunl/dump/ /pritunl/dump/." >> pritunl-restore.sh
echo "sudo aws s3 cp s3://${pritunlbucket}/pritunl/pritunl.uuid /var/lib/pritunl/pritunl.uuid" >> pritunl-restore.sh
echo "sudo mongorestore --nsInclude '*' /pritunl/dump/" >> pritunl-restore.sh
echo "sudo service pritunl start" >> pritunl-restore.sh

echo "Restoring..."
sudo /pritunl/pritunl-restore.sh

#Setup CRON for backups:
echo "Setup CRON for backups..."
sudo echo "0 * * * * /pritunl/pritunl-backup.sh #Runs hourly on the :00" >> pritunlcronjobs
sudo crontab pritunlcronjobs
sleep 10

#Start the Pritunl server:
sudo service pritunl status

exit 0
