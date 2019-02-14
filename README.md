# cleanup_account_from_external-source_satellite

About this script, currently, we are checking all local accounts (originally created using an External Source) and checking on the External Sources (on this version, will be necessary you define the valid External Source you would like to check.


First run, all users from External Sources
```
# ./check_ad.sh
External Sources: w2k8 w2k8-2
User: waldirio, External Source: w2k8, Status: true
User: user1, External Source: w2k8-2, Status: true
User: user2, External Source: w2k8-2, Status: true
User: user3, External Source: w2k8-2, Status: true
```

Now, some users were deleted from External Source
```
# ./check_ad.sh
External Sources: w2k8 w2k8-2
User: waldirio, External Source: w2k8, Status: true
User: user1, External Source: w2k8-2, Status: false
Removing user **JUST SHOWING**
hammer -u admin -p redhat user delete --login user1
User: user2, External Source: w2k8-2, Status: false
Removing user **JUST SHOWING**
hammer -u admin -p redhat user delete --login user2
User: user3, External Source: w2k8-2, Status: false
Removing user **JUST SHOWING**
hammer -u admin -p redhat user delete --login user3
```
Note. By default, the line to effectively remove the account is commented (line 71 as you can see below)

```
 69       ## Uncomment the line below ONLY if you would like to remove the entry from your Satellite
 70       ## Do it at your own risk.
 71       # $HAMMER user delete --login $user_name
 72       echo "Removing user **JUST SHOWING**"
 73       echo "$HAMMER user delete --login $user_name"
```

At this time, uncommenting the line
```
# ./check_ad.sh
External Sources: w2k8 w2k8-2
User: waldirio, External Source: w2k8, Status: true

User: user1, External Source: w2k8-2, Status: false
User [user1] deleted
Removing user **JUST SHOWING**
hammer -u admin -p redhat user delete --login user1

User: user2, External Source: w2k8-2, Status: false
User [user2] deleted
Removing user **JUST SHOWING**
hammer -u admin -p redhat user delete --login user2

User: user3, External Source: w2k8-2, Status: false
User [user3] deleted
Removing user **JUST SHOWING**
hammer -u admin -p redhat user delete --login user3
```

Before you start, let me show what will be necessary the modification

```
 9 # Variables
10 #---
11 HAMMER="hammer -u admin -p redhat"
12 STAGE="/tmp/list.log"
13 
14 ## PLEASE UPDATE THE LIST BELOW WITH THE INFO FROM YOUR ENVIRONMENT
15 ## Command to retrieve the complete list
16 ## hammer auth-source ldap list
17 
18 external_source="w2k8 w2k8-2"
19 #---
```

Line 11. If you need pass some additional parameter, do it only here, if not, you can keep just the command "hammer" and will be enough
Line 18. Will be necessary add the external sources, you will be able to get the name with the command there. Below the output from my lab
```
# hammer -u admin -p redhat auth-source ldap list
---|--------|--------|------|---------------
ID | NAME   | LDAPS? | PORT | SERVER TYPE   
---|--------|--------|------|---------------
4  | idm    |        | 389  | AuthSourceLdap
3  | w2k8   |        | 389  | AuthSourceLdap
6  | w2k8-2 |        | 389  | AuthSourceLdap
---|--------|--------|------|---------------
```
