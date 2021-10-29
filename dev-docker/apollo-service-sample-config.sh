#!/bin/bash
APP_ID="89089012783789789719823798127398"
PASSWORD="12345679"
CLUSTERNAME="development"
ENVIRONMENT=`echo $CLUSTERNAME | tr a-z A-Z`
APP_HOST=$1

# ApolloConfigDB
echo server namespace
mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloConfigDB -e "INSERT INTO AppNamespace (Name, AppId, Comment, DataChange_CreatedBy, DataChange_LastModifiedBy) SELECT \"$APP_HOST\", $APP_ID, \"$APP_HOST namespace\", \"apollo\", \"apollo\" FROM DUAL WHERE NOT EXISTS (SELECT * FROM AppNamespace WHERE AppId=\"$APP_ID\" AND Name=\"$APP_HOST\");"

echo server namespace env
mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloConfigDB -e "INSERT INTO Namespace (AppId, ClusterName, NamespaceName, DataChange_CreatedBy, DataChange_LastModifiedBy) SELECT $APP_ID, \"$CLUSTERNAME\", \"$APP_HOST\", \"apollo\", \"apollo\" FROM DUAL WHERE NOT EXISTS (SELECT * FROM Namespace WHERE AppId=\"$APP_ID\" AND ClusterName=\"$CLUSTERNAME\" and NamespaceName=\"$APP_HOST\");"


echo server namespace
mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO AppNamespace (Name, AppId, Comment, DataChange_CreatedBy, DataChange_LastModifiedBy) SELECT \"$APP_HOST\", $APP_ID, \"$APP_HOST namespace\", \"apollo\", \"apollo\" FROM DUAL WHERE NOT EXISTS (SELECT * FROM AppNamespace WHERE AppId=\"$APP_ID\" AND Name=\"$APP_HOST\");"

echo appid server permission
mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Permission (PermissionType, TargetId, DataChange_CreatedBy, DataChange_LastModifiedBy) SELECT \"ModifyNamespace\", \"$APP_ID+$APP_HOST\", \"apollo\", \"apollo\" FROM DUAL WHERE NOT EXISTS (SELECT * FROM Permission WHERE TargetId=\"$APP_ID+$APP_HOST\" AND PermissionType=\"ModifyNamespace\");"
mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Permission (PermissionType, TargetId, DataChange_CreatedBy, DataChange_LastModifiedBy) SELECT \"ReleaseNamespace\", \"$APP_ID+$APP_HOST\", \"apollo\", \"apollo\" FROM DUAL WHERE NOT EXISTS (SELECT * FROM Permission WHERE TargetId=\"$APP_ID+$APP_HOST\" AND PermissionType=\"ReleaseNamespace\");"
mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Permission (PermissionType, TargetId, DataChange_CreatedBy, DataChange_LastModifiedBy) SELECT \"ModifyNamespace\", \"$APP_ID+$APP_HOST+$ENVIRONMENT\", \"apollo\", \"apollo\" FROM DUAL WHERE NOT EXISTS (SELECT * FROM Permission WHERE TargetId=\"$APP_ID+$APP_HOST+$ENVIRONMENT\" AND PermissionType=\"ModifyNamespace\");"
mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Permission (PermissionType, TargetId, DataChange_CreatedBy, DataChange_LastModifiedBy) SELECT \"ReleaseNamespace\", \"$APP_ID+$APP_HOST+$ENVIRONMENT\", \"apollo\", \"apollo\" FROM DUAL WHERE NOT EXISTS (SELECT * FROM Permission WHERE TargetId=\"$APP_ID+$APP_HOST+$ENVIRONMENT\" AND PermissionType=\"ReleaseNamespace\");"

echo appid server role
mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Role (RoleName, DataChange_CreatedBy, DataChange_LastModifiedBy) SELECT \"ModifyNamespace+$APP_ID+$APP_HOST\", \"apollo\", \"apollo\" FROM DUAL WHERE NOT EXISTS (SELECT * FROM Role WHERE RoleName=\"ModifyNamespace+$APP_ID+$APP_HOST\");"
mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Role (RoleName, DataChange_CreatedBy, DataChange_LastModifiedBy) SELECT \"ReleaseNamespace+$APP_ID+$APP_HOST\", \"apollo\", \"apollo\" FROM DUAL WHERE NOT EXISTS (SELECT * FROM Role WHERE RoleName=\"ReleaseNamespace+$APP_ID+$APP_HOST\");"
mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Role (RoleName, DataChange_CreatedBy, DataChange_LastModifiedBy) SELECT \"ModifyNamespace+$APP_ID+$APP_HOST+$ENVIRONMENT\", \"apollo\", \"apollo\" FROM DUAL WHERE NOT EXISTS (SELECT * FROM Role WHERE RoleName=\"ModifyNamespace+$APP_ID+$APP_HOST+$ENVIRONMENT\");"
mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Role (RoleName, DataChange_CreatedBy, DataChange_LastModifiedBy) SELECT \"ReleaseNamespace+$APP_ID+$APP_HOST+$ENVIRONMENT\", \"apollo\", \"apollo\" FROM DUAL WHERE NOT EXISTS (SELECT * FROM Role WHERE RoleName=\"ReleaseNamespace+$APP_ID+$APP_HOST+$ENVIRONMENT\");"

echo server permission
id=`mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloConfigDB -e "select Id from Namespace where NamespaceName=\"$APP_HOST\";"`
appnamespaceid=`echo $id | awk '{ print $2 }'`

mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloConfigDB -e "INSERT INTO Item (NamespaceId, \`Key\`, Value, LineNum, DataChange_CreatedBy, DataChange_LastModifiedBy) SELECT $appnamespaceid, \"database_name\", \"test\", 1, \"apollo\", \"apollo\" FROM DUAL WHERE NOT EXISTS (SELECT * FROM Item WHERE NamespaceId=\"$appnamespaceid\" AND \`Key\`=\"database_name\");"

modifyrole=`mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "select Id from Role where RoleName=\"ModifyNamespace+$APP_ID+$APP_HOST\";"`
modifyroleid=`echo $modifyrole | awk '{ print $2 }'`
modifyrolepermission=`mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "select Id from Permission where PermissionType=\"ModifyNamespace\" and TargetId=\"$APP_ID+$APP_HOST\";"`
modifyrolepermissionid=`echo $modifyrolepermission | awk -F 'Id ' '{ print $2 }'`
for permissionid in $modifyrolepermissionid;do
	mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO RolePermission (RoleId, PermissionId, DataChange_CreatedBy, DataChange_LastModifiedBy) SELECT $modifyroleid, $permissionid, \"apollo\", \"apollo\" FROM DUAL WHERE NOT EXISTS (SELECT * FROM RolePermission WHERE RoleId=\"$modifyroleid\" AND PermissionId=\"$permissionid\");"
done
 
releaserole=`mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "select Id from Role where RoleName=\"ReleaseNamespace+$APP_ID+$APP_HOST\";"`
releaseroleid=`echo $releaserole | awk '{ print $2 }'`
releaserolepermission=`mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "select Id from Permission where PermissionType=\"ReleaseNamespace\" and TargetId=\"$APP_ID+$APP_HOST\";"`
releaserolepermissionid=`echo $releaserolepermission | awk -F 'Id ' '{ print $2 }'`
for permissionid in $releaserolepermissionid;do
	mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO RolePermission (RoleId, PermissionId, DataChange_CreatedBy, DataChange_LastModifiedBy) SELECT $releaseroleid, $permissionid, \"apollo\", \"apollo\" FROM DUAL WHERE NOT EXISTS (SELECT * FROM RolePermission WHERE RoleId=\"$releaseroleid\" AND PermissionId=\"$permissionid\");"
done

modifyrole_env=`mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "select Id from Role where RoleName=\"ModifyNamespace+$APP_ID+$APP_HOST+$ENVIRONMENT\";"`
modifyroleid_env=`echo $modifyrole_env | awk '{ print $2 }'`
modifyrolepermission_env=`mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "select Id from Permission where PermissionType=\"ModifyNamespace\" and TargetId=\"$APP_ID+$APP_HOST+$ENVIRONMENT\";"`
modifyrolepermissionid_env=`echo $modifyrolepermission_env | awk -F 'Id ' '{ print $2 }'`
for permissionid in $modifyrolepermissionid_env;do
	mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO RolePermission (RoleId, PermissionId, DataChange_CreatedBy, DataChange_LastModifiedBy) SELECT $modifyroleid_env, $permissionid, \"apollo\", \"apollo\" FROM DUAL WHERE NOT EXISTS (SELECT * FROM RolePermission WHERE RoleId=\"$modifyroleid_env\" AND PermissionId=\"$permissionid\");"
done

releaserole_env=`mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "select Id from Role where RoleName=\"ReleaseNamespace+$APP_ID+$APP_HOST+$ENVIRONMENT\";"`
releaseroleid_env=`echo $releaserole_env | awk '{ print $2 }'`
releaserolepermission_env=`mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "select Id from Permission where PermissionType=\"ReleaseNamespace\" and TargetId=\"$APP_ID+$APP_HOST+$ENVIRONMENT\";"`
releaserolepermissionid_env=`echo $releaserolepermission_env | awk -F 'Id ' '{ print $2 }'`
for permissionid in $releaserolepermissionid_env;do
	mysql -uroot -p$PASSWORD -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO RolePermission (RoleId, PermissionId, DataChange_CreatedBy, DataChange_LastModifiedBy) SELECT $releaseroleid_env, $permissionid, \"apollo\", \"apollo\" FROM DUAL WHERE NOT EXISTS (SELECT * FROM RolePermission WHERE RoleId=\"$releaseroleid_env\" AND PermissionId=\"$permissionid\");"
done
