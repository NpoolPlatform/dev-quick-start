# dev-quick-start

## 创建minikube用户（root用户执行）
```
echo y | adduser minikube
echo minikube:12345679 | chpasswd
echo "minikube ALL = (root) NOPASSWD:ALL" | tee /etc/sudoers.d/minikube
gpasswd -a minikube docker
```

## 快速搭建k8s测试环境（minikube用户执行）
- su minikube
- ./dev-setup.sh -t setup -i $MY_HOSTIP
- 如果需要测试的仓库已创建，```./dev-setup.sh -t setup -i $MY_HOSTIP -H $apphost -D $app_database -A $all_proxy```

## apollo添加基础服务配置-自动版（minikube用户执行）
- su minikube
- ./dev-setup.sh -t config -A $appid -H $apphost -D $app_database -A $all_proxy
- appid取yaml中的配置，apphost为hostname将'.'替换成'-'
- 登陆apollo页面，选择app应用后点击发布即可

## apollo添加基础服务配置-手动版（http://$MY_HOSTIP:8070/）
- 创建应用
- 创建该应用development集群
- 创建mysql-npool-top namespace以及key,value
  - username:root
  - password:12345679
- 创建$apphost namespace以及key,value(apphost=`cat cmd/*/*.viper.yaml | grep hostname | awk '{print $2}' | sed 's/"//g' | sed 's/\./-/g'`)
  - database_name:$app-databasename
- 创建redis-npool-top namespace以及key,value
  - username:root
  - password:12345679
- 创建rabbitmq-npool-top namespace以及key,value
  - username:user
  - password:12345679

## 开始构建你的app（k8s pod中执行）
```
ssh方法一
su minikube
minikube ssh
dockerid=`docker ps -a | grep box | awk '{ print $1 }'`
docker exec -it $dockerid /bin/bash
service ssh restart

ssh方法二
需先执行方法一
ssh -p 22222 root@192.168.49.2

git clone https://github.com/NpoolPlatform/$appname.git
cd $appname
go get -u golang.org/x/lint/golint
go get github.com/tebeka/go2xunit
go get github.com/t-yuki/gocover-cobertura
go get golang.org/x/image/tiff/lzw
go get github.com/boombuler/barcode
make deps

make verify
make verify-build

```

## 创建app需要的vhost以及权限设置-手动版（宿主机切换minikube用户执行）
```
su minikube
kubectl exec -it --namespace kube-system rabbitmq-0 -- rabbitmqctl add_vhost $apphost
kubectl exec -it --namespace kube-system rabbitmq-0 -- rabbitmqctl set_permissions -p $apphost user ".*" ".*" ".*"
```

## 运行app server（k8s pod中执行）
```
ssh方法一
su minikube
minikube ssh
dockerid=`docker ps -a | grep box | awk '{ print $1 }'`
docker exec -it $dockerid /bin/bash
service ssh restart

ssh方法二
需先执行方法一
ssh -p 22222 root@192.168.49.2

cd $appname
cp output/linux/amd64/$app-service cmd/$appname/
cd cmd/$app-service/
./$app-service run
```

## 清除k8s环境（minikube用户执行）
```
su minikube
./dev-setup.sh -t destroy
```

## 服务地址
- consul ```http://$MY_HOSTIP:8500/```
- apollo ```http://$MY_HOSTIP:8070/```
- rabbitmq ```http://$MY_HOSTIP:15672/```
- minio ```http://$MY_HOSTIP:9000/```

## 登陆mysql
mysql -uroot -p12345679 -h 192.168.49.2 -P 30306
