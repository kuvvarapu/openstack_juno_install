#!/bin/bash -x
#This script is used to install prerequsites for heat installation
#Author kkk
#Date: 20/11/2014

#Create a mysql database
#database configuration
mysql -u root -ptoor << EODs
CREATE DATABASE heat;
GRANT ALL PRIVILEGES ON heat.* TO 'heat'@'localhost' \
  IDENTIFIED BY 'heat';
GRANT ALL PRIVILEGES ON heat.* TO 'heat'@'%' \
  IDENTIFIED BY 'heat';
EODs

# Identity service credentials
keystone user-create --name heat --pass heat
#Role
keystone user-role-add --user heat --tenant service --role admin
keystone role-create --name heat_stack_user
keystone role-create --name heat_stack_owner
keystone service-create --name heat --type orchestration \
  --description "Orchestration"
 keystone service-create --name heat-cfn --type cloudformation \
--description "Orchestration"
#Endpoints
keystone endpoint-create \
  --service-id $(keystone service-list | awk '/ orchestration / {print $2}') \
  --publicurl http://controller:8004/v1/%\(tenant_id\)s \
  --internalurl http://controller:8004/v1/%\(tenant_id\)s \
  --adminurl http://controller:8004/v1/%\(tenant_id\)s \
--region regionOne
#Endpoints
keystone endpoint-create \
  --service-id $(keystone service-list | awk '/ cloudformation / {print $2}') \
  --publicurl http://controller:8000/v1 \
  --internalurl http://controller:8000/v1 \
  --adminurl http://controller:8000/v1 \
  --region regionOne

#Installing the service
apt-get install heat-api heat-api-cfn heat-engine python-heatclient
#Edit the heat config file
sed -i '/sqlite_db/ a connection=mysql:\/\/heat:heat@controller\/heat' /etc/heat/heat.conf

#Backend
sed -i '/rpc_backend=/ a\
rpc_backend=rabbit \
rabbit_host=controller\
rabbit_passwdor=guest' /etc/heat/heat.conf

#
sed -i '/keystone_authtoken/ a\
auth_uri = http://controller:5000/v2.0\
identity_uri = http://controller:35357\
admin_tenant_name = service\
admin_user = heat\
admin_password = heat' /etc/heat/heat.conf 

 
sed -i '/ec2authtoken/ a\
auth_uri = http://controller:5000/v2.0' /etc/heat/heat.conf

sed -i '/instance_user/ a\
heat_metadata_server_url = http://controller:8000 \
heat_waitcondition_server_url = http://controller:8000/v1/waitcondition' /etc/heat/heat.conf

#
 heat-manage db_sync

