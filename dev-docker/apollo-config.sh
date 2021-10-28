#!/bin/bash
APP_ID=$1
APP_HOST=$2

# ApolloConfigDB
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloConfigDB -e "INSERT INTO App (AppId, Name, OrgId, OrgName, OwnerName, OwnerEmail,DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES ($APP_ID, \"test\", \"TEST1\", \"样例部门1\", \"apollo\", \"apollo@acme.com\", \"apollo\", \"apollo\")"

mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloConfigDB -e "INSERT INTO AppNamespace (Name, AppId, Comment, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES (\"application\", $APP_ID, \"default app namespace\", \"apollo\", \"apollo\");"
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloConfigDB -e "INSERT INTO AppNamespace (Name, AppId, Comment, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES (\"mysql-npool-top\", $APP_ID, \"mysql\", \"apollo\", \"apollo\");"
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloConfigDB -e "INSERT INTO AppNamespace (Name, AppId, Comment, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES (\"redis-npool-top\", $APP_ID, \"redis\", \"apollo\", \"apollo\");"
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloConfigDB -e "INSERT INTO AppNamespace (Name, AppId, Comment, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES (\"rabbitmq-npool-top\", $APP_ID, \"rabbitmq\", \"apollo\", \"apollo\");"
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloConfigDB -e "INSERT INTO AppNamespace (Name, AppId, Comment, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES (\"$APP_HOST\", $APP_ID, \"app server\", \"apollo\", \"apollo\");"

mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloConfigDB -e "INSERT INTO Cluster (Name, AppId, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES (\"development\", $APP_ID, \"apollo\", \"apollo\");"

mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloConfigDB -e "INSERT INTO Namespace (AppId, ClusterName, NamespaceName, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES ($APP_ID, \"development\", \"application\", \"apollo\", \"apollo\");"
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloConfigDB -e "INSERT INTO Namespace (AppId, ClusterName, NamespaceName, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES ($APP_ID, \"development\", \"mysql-npool-top\", \"apollo\", \"apollo\");"
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloConfigDB -e "INSERT INTO Namespace (AppId, ClusterName, NamespaceName, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES ($APP_ID, \"development\", \"redis-npool-top\", \"apollo\", \"apollo\");"
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloConfigDB -e "INSERT INTO Namespace (AppId, ClusterName, NamespaceName, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES ($APP_ID, \"development\", \"rabbitmq-npool-top\", \"apollo\", \"apollo\");"
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloConfigDB -e "INSERT INTO Namespace (AppId, ClusterName, NamespaceName, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES ($APP_ID, \"development\", \"$APP_HOST\", \"apollo\", \"apollo\");"

# item 
# mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloConfigDB -e ""

# ApolloPortalDB
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO App (AppId, Name, OrgId, OrgName, OwnerName, OwnerEmail,DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES ($APP_ID, \"test\", \"TEST1\", \"样例部门1\", \"apollo\", \"apollo\", \"apollo\", \"apollo\");"
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO AppNamespace (Name, AppId, Comment, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES (\"application\", $APP_ID, \"default app namespace\", \"apollo\", \"apollo\");"
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO AppNamespace (Name, AppId, Comment, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES (\"mysql-npool-top\", $APP_ID, \"mysql\", \"apollo\", \"apollo\");"
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO AppNamespace (Name, AppId, Comment, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES (\"redis-npool-top\", $APP_ID, \"redis\", \"apollo\", \"apollo\");"
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO AppNamespace (Name, AppId, Comment, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES (\"rabbitmq-npool-top\", $APP_ID, \"rabbitmq\", \"apollo\", \"apollo\");"
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO AppNamespace (Name, AppId, Comment, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES (\"$APP_HOST\", $APP_ID, \"app server\", \"apollo\", \"apollo\");"

mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Permission (PermissionType, TargetId, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES (\"CreateCluster\", $APP_ID, \"apollo\", \"apollo\");"
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Permission (PermissionType, TargetId, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES (\"CreateNamespace\", $APP_ID, \"apollo\", \"apollo\");"
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Permission (PermissionType, TargetId, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES (\"AssignRole\", $APP_ID, \"apollo\", \"apollo\");"
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Permission (PermissionType, TargetId, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES (\"ManageAppMaster\", $APP_ID, \"apollo\", \"apollo\");"

mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Permission (PermissionType, TargetId, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES (\"ModifyNamespace\", \"$APP_ID+application\", \"apollo\", \"apollo\");"
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Permission (PermissionType, TargetId, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES (\"ReleaseNamespace\", \"$APP_ID+application\", \"apollo\", \"apollo\");"
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Permission (PermissionType, TargetId, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES (\"ModifyNamespace\", \"$APP_ID+application+DEVELOPMENT\", \"apollo\", \"apollo\");"
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Permission (PermissionType, TargetId, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES (\"ReleaseNamespace\", \"$APP_ID+application+DEVELOPMENT\", \"apollo\", \"apollo\");"

mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Permission (PermissionType, TargetId, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES (\"ModifyNamespace\", \"$APP_ID+mysql-npool-top\", \"apollo\", \"apollo\");"
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Permission (PermissionType, TargetId, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES (\"ReleaseNamespace\", \"$APP_ID+mysql-npool-top\", \"apollo\", \"apollo\");"
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Permission (PermissionType, TargetId, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES (\"ModifyNamespace\", \"$APP_ID+mysql-npool-top+DEVELOPMENT\", \"apollo\", \"apollo\");"
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Permission (PermissionType, TargetId, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES (\"ReleaseNamespace\", \"$APP_ID+mysql-npool-top+DEVELOPMENT\", \"apollo\", \"apollo\");"

mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Permission (PermissionType, TargetId, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES (\"ModifyNamespace\", \"$APP_ID+redis-npool-top\", \"apollo\", \"apollo\");"
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Permission (PermissionType, TargetId, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES (\"ReleaseNamespace\", \"$APP_ID+redis-npool-top\", \"apollo\", \"apollo\");"
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Permission (PermissionType, TargetId, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES (\"ModifyNamespace\", \"$APP_ID+redis-npool-top+DEVELOPMENT\", \"apollo\", \"apollo\");"
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Permission (PermissionType, TargetId, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES (\"ReleaseNamespace\", \"$APP_ID+redis-npool-top+DEVELOPMENT\", \"apollo\", \"apollo\");"

mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Permission (PermissionType, TargetId, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES (\"ModifyNamespace\", \"$APP_ID+rabbitmq-npool-top\", \"apollo\", \"apollo\");"
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Permission (PermissionType, TargetId, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES (\"ReleaseNamespace\", \"$APP_ID+rabbitmq-npool-top\", \"apollo\", \"apollo\");"
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Permission (PermissionType, TargetId, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES (\"ModifyNamespace\", \"$APP_ID+rabbitmq-npool-top+DEVELOPMENT\", \"apollo\", \"apollo\");"
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Permission (PermissionType, TargetId, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES (\"ReleaseNamespace\", \"$APP_ID+rabbitmq-npool-top+DEVELOPMENT\", \"apollo\", \"apollo\");"

mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Permission (PermissionType, TargetId, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES (\"ModifyNamespace\", \"$APP_ID+$APP_HOST\", \"apollo\", \"apollo\");"
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Permission (PermissionType, TargetId, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES (\"ReleaseNamespace\", \"$APP_ID+$APP_HOST\", \"apollo\", \"apollo\");"
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Permission (PermissionType, TargetId, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES (\"ModifyNamespace\", \"$APP_ID+$APP_HOST+DEVELOPMENT\", \"apollo\", \"apollo\");"
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloPortalDB -e "INSERT INTO Permission (PermissionType, TargetId, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES (\"ReleaseNamespace\", \"$APP_ID+$APP_HOST+DEVELOPMENT\", \"apollo\", \"apollo\");"


id=`mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloConfigDB -e "select Id from Namespace where NamespaceName=\"mysql-npool-top\";"`
mysqlnamespaceid=`echo $id | awk '{ print $2 }'`
id=`mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloConfigDB -e "select Id from Namespace where NamespaceName=\"redis-npool-top\";"`
redisnamespaceid=`echo $id | awk '{ print $2 }'`
id=`mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloConfigDB -e "select Id from Namespace where NamespaceName=\"rabbitmq-npool-top\";"`
rabbitmqnamespaceid=`echo $id | awk '{ print $2 }'`
id=`mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloConfigDB -e "select Id from Namespace where NamespaceName=\"$APP_HOST\";"`
appnamespaceid=`echo $id | awk '{ print $2 }'`

echo $mysqlnamespaceid
echo $redisnamespaceid
echo $rabbitmqnamespaceid
echo $appnamespaceid
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloConfigDB -e "INSERT INTO Item (NamespaceId, \`Key\`, Value, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES ($mysqlnamespaceid, \"username\", \"root\", \"apollo\", \"apollo\");"
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloConfigDB -e "INSERT INTO Item (NamespaceId, \`Key\`, Value, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES ($mysqlnamespaceid, \"password\", \"12345679\", \"apollo\", \"apollo\");"
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloConfigDB -e "INSERT INTO Item (NamespaceId, \`Key\`, Value, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES ($redisnamespaceid, \"username\", \"root\", \"apollo\", \"apollo\");"
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloConfigDB -e "INSERT INTO Item (NamespaceId, \`Key\`, Value, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES ($redisnamespaceid, \"password\", \"12345679\", \"apollo\", \"apollo\");"
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloConfigDB -e "INSERT INTO Item (NamespaceId, \`Key\`, Value, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES ($rabbitmqnamespaceid, \"username\", \"user\", \"apollo\", \"apollo\");"
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloConfigDB -e "INSERT INTO Item (NamespaceId, \`Key\`, Value, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES ($rabbitmqnamespaceid, \"password\", \"12345679\", \"apollo\", \"apollo\");"
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 -D ApolloConfigDB -e "INSERT INTO Item (NamespaceId, \`Key\`, Value, DataChange_CreatedBy, DataChange_LastModifiedBy) VALUES ($appnamespaceid, \"database_name\", \"test\", \"apollo\", \"apollo\");"
