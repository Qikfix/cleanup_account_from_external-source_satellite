#!/bin/bash

# 
# Date ....: 02/14/2019
# Dev .....: Joniel <joniel.pasqualetto@redhat.com> Waldirio <waldirio@redhat.com>
# Purpose .: Match the user from Satellite (local database) and AD (external source).
# 

# Variables
#---
HAMMER="hammer -u admin -p redhat"
STAGE="/tmp/list.log"

## PLEASE UPDATE THE LIST BELOW WITH THE INFO FROM YOUR ENVIRONMENT
## Command to retrieve the complete list
## hammer auth-source ldap list

external_source="w2k8 w2k8-2"
#---

# Complete user list
user_id_list=$($HAMMER --csv user list | grep -v ^Id | cut -d, -f1)

> $STAGE

# External Sources
echo "External Sources: $external_source"

user_info()
{
  for b in $user_id_list
  do
    $HAMMER --csv user info --id $b | grep -v ^Id | cut -d, -f2,6 >> $STAGE
  done

  external_source
}

external_source()
{
  for b in $external_source
  do
    group_user=$(grep "$b$" $STAGE)
    check_ad "$group_user" $b
  done
}

check_ad()
{
group_user=$1
group=$2

auth_source_id=$($HAMMER --csv auth-source ldap list | grep "$group," | cut -d, -f1)

for b in $group_user
do
  user_name=$(echo $b | cut -d, -f1)
  external_source_name=$(echo $b | cut -d, -f2)

  aux=$(echo "conf.echo=false
  source_now = AuthSourceLdap.find_by_id($auth_source_id)
  conn = source_now.ldap_con
  conf.echo=true
  conn.valid_user?('$user_name')" | foreman-rake console 2>/dev/null | grep -A1 valid_user | tail -1)

  echo "User: $user_name, External Source: $external_source_name, Status: $aux"
  if [ $aux == "false" ];
    then
      ## Uncomment the line below ONLY if you would like to remove the entry from your Satellite
      ## Do it at your own risk.
      # $HAMMER user delete --login $user_name
      echo "Removing user **JUST SHOWING**"
      echo "$HAMMER user delete --login $user_name"
  fi
done
}

# Main
user_info
