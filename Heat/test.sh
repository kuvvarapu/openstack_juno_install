#!/bin/bash -x
#This script is used to install prerequsites for heat installation
#Author kkk
#Date: 20/11/2014

#Checking whether mysql server is running or not
declare -r TRUE=0
declare -r FALSE=1

#Checking the CUrrent User
root_Check(){
	[ $(id -u) -eq "0" ] && return $TRUE || return $FALSE
}
root_Check && echo "Root User" || echo "Not a root user"

#Checking the mysql
mysql_Check(){
	
	status=`service mysql status > /dev/null`
	[ "$?" -eq "0" ] && return $TRUE || return $FALSE
	
}

mysql_Check && echo "mysql service is running" || echo "mysql service is stoped"

#Checking the Keystone
keystone_Check(){
	KS=`netstat -tl|grep 35357 || netstat -tl|grep 5000`
	[ "$?" -eq "0" ] && return $TRUE || return $FALSE
}
keystone_Check && echo "Keystone service is running" || echo "Keystone service is not running"

#Checking the Glance
glance_Check(){
	GC=`netstat -tl|grep 9696`
	[ "$?" -eq "0" ] && return $TRUE || return $FALSE
}
glance_Check && echo "Glance service is running" || echo "Glance service is not running"



	 
