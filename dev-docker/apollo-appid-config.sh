#!/bin/bash
APP_ID="89089012783789789719823798127398"
PASSWORD="12345679"
CLUSTERNAME="development"
ENVIRONMENT="DEVELOPMENT"
APP_HOST="mysql-npool-top"

# ApolloConfigDB
echo appid info
mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloConfigDB -e "INSERT INTO App (AppId, Name, OrgId, OrgName, OwnerName, OwnerEmail,DataChange_CreatedBy, DataChange_LastModifiedBy) SELECT $APP_ID, \"test\", \"TEST1\", \"npool\", \"apollo\", \"apollo@acme.com\", \"apollo\", \"apollo\" FROM DUAL WHERE NOT EXISTS (SELECT * FROM App WHERE AppId=\"$APP_ID\");"

echo cluster
mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloConfigDB -e "INSERT INTO Cluster (Name, AppId, DataChange_CreatedBy, DataChange_LastModifiedBy) SELECT \"$CLUSTERNAME\", $APP_ID, \"apollo\", \"apollo\" FROM DUAL WHERE NOT EXISTS (SELECT * FROM Cluster WHERE AppId="$APP_ID" AND Name=\"$CLUSTERNAME\");"

mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO App (AppId, Name, OrgId, OrgName, OwnerName, OwnerEmail,DataChange_CreatedBy, DataChange_LastModifiedBy) SELECT $APP_ID, \"test\", \"TEST1\", \"npool\", \"apollo\", \"apollo@acme.com\", \"apollo\", \"apollo\" FROM DUAL WHERE NOT EXISTS (SELECT * FROM App WHERE AppId=\"$APP_ID\");"


echo appid permission
mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Permission (PermissionType, TargetId, DataChange_CreatedBy, DataChange_LastModifiedBy) SELECT \"CreateCluster\", $APP_ID, \"apollo\", \"apollo\" FROM DUAL WHERE NOT EXISTS (SELECT * FROM Permission WHERE TargetId=\"$APP_ID\" AND PermissionType=\"CreateCluster\");"
mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Permission (PermissionType, TargetId, DataChange_CreatedBy, DataChange_LastModifiedBy) SELECT \"CreateNamespace\", $APP_ID, \"apollo\", \"apollo\" FROM DUAL WHERE NOT EXISTS (SELECT * FROM Permission WHERE TargetId=\"$APP_ID\" AND PermissionType=\"CreateNamespace\");"
mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Permission (PermissionType, TargetId, DataChange_CreatedBy, DataChange_LastModifiedBy) SELECT \"AssignRole\", $APP_ID, \"apollo\", \"apollo\" FROM DUAL WHERE NOT EXISTS (SELECT * FROM Permission WHERE TargetId=\"$APP_ID\" AND PermissionType=\"AssignRole\");"
mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Permission (PermissionType, TargetId, DataChange_CreatedBy, DataChange_LastModifiedBy) SELECT \"ManageAppMaster\", $APP_ID, \"apollo\", \"apollo\" FROM DUAL WHERE NOT EXISTS (SELECT * FROM Permission WHERE TargetId=\"$APP_ID\" AND PermissionType=\"ManageAppMaster\");"


echo appid role
mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Role (RoleName, DataChange_CreatedBy, DataChange_LastModifiedBy) SELECT \"Master+$APP_ID\", \"apollo\", \"apollo\" FROM DUAL WHERE NOT EXISTS (SELECT * FROM Role WHERE RoleName=\"Master+$APP_ID\");"
mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Role (RoleName, DataChange_CreatedBy, DataChange_LastModifiedBy) SELECT \"ManageAppMaster+$APP_ID\", \"apollo\", \"apollo\" FROM DUAL WHERE NOT EXISTS (SELECT * FROM Role WHERE RoleName=\"ManageAppMaster+$APP_ID\");"

master=`mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "select Id from Role where RoleName=\"Master+$APP_ID\";"`
masterroleid=`echo $master | awk '{ print $2 }'`
masterpermission=`mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "select Id from Permission where (PermissionType=\"AssignRole\" or PermissionType=\"CreateCluster\" or PermissionType=\"CreateNamespace\") and TargetId=\"$APP_ID\";"`
masterpermissionid=`echo $masterpermission | awk -F 'Id ' '{ print $2 }'`
for permissionid in $masterpermissionid;do
	mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO RolePermission (RoleId, PermissionId, DataChange_CreatedBy, DataChange_LastModifiedBy) SELECT $masterroleid, $permissionid, \"apollo\", \"apollo\" FROM DUAL WHERE NOT EXISTS (SELECT * FROM RolePermission WHERE RoleId=\"$masterroleid\" AND PermissionId=\"$permissionid\");"
done
# 
manageappmaster=`mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "select Id from Role where RoleName=\"ManageAppMaster+$APP_ID\";"`
manageroleid=`echo $manageappmaster | awk '{ print $2 }'`
managerpermission=`mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "select Id from Permission where PermissionType=\"ManageAppMaster\" and TargetId=\"$APP_ID\";"`
managerpermissionid=`echo $managerpermission | awk -F 'Id ' '{ print $2 }'`
for permissionid in $managerpermissionid;do
	mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO RolePermission (RoleId, PermissionId, DataChange_CreatedBy, DataChange_LastModifiedBy) SELECT $manageroleid, $permissionid, \"apollo\", \"apollo\" FROM DUAL WHERE NOT EXISTS (SELECT * FROM RolePermission WHERE RoleId=\"$manageroleid\" AND PermissionId=\"$permissionid\");"
done
