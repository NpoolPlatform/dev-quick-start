# dev-quick-start

## 创建minikube用户
```
echo y | adduser minikube
echo minikube:12345679 | chpasswd
echo "minikube ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/minikube
```

## 快速搭建k8s测试环境
- 切换到minikube用户后执行命令 ./dev-setup.sh -t setup -i $MY_HOSTIP


## apollo添加基础服务配置（http://$MY_HOSTIP:8070/）
- 创建应用
- 创建该应用development集群
- 创建mysql-npool-top namespace以及key,value
  - username:root
  - password:12345679
- 创建$appname namespace以及key,value
  - database_name:$app-databasename
- 创建redis-npool-top namespace以及key,value
  - username:root
  - password:12345679
- 创建rabbitmq-npool-top namespace以及key,value
  - username:user
  - password:12345679

## 在运行k8s集群的虚机上运行开发环境docker
```
docker run -d -e ENV_ENVIRONMENT_TARGET=developnment -e ENV_CONSUL_HOST=http://$MY_HOSTIP -e ENV_CONSUL_PORT=8500 -e PATH=/go-go1.16.5/bin:$PATH -e GOPROXY=https://goproxy.cn,direct --name devtest -v /sys/fs/cgroup:/sys/fs/cgroup:ro --privileged catwo/devtest
docker exec -it devtest /bin/bash
/etc/hosts添加以下内容
$MY_HOSTIP apollo-configservice.kube-system.svc.cluster.local
$MY_HOSTIP rabbitmq.kube-system.svc.cluster.local
```

## 开始构建你的app(docker内执行)
```
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

获取你的app hostname
apphost=`cat cmd/*/*.viper.yaml | grep hostname | awk '{print $2}' | sed 's/"//g' | sed 's/\./-/g'`
```

## 创建app需要的vhost以及权限设置(宿主机切换minikube用户执行)
```
kubectl exec -it --namespace kube-system rabbitmq-0 -- rabbitmqctl add_vhost $apphost
kubectl exec -it --namespace kube-system rabbitmq-0 -- rabbitmqctl set_permissions -p $apphost user ".*" ".*" ".*"
```

## 运行app server(docker内执行)
```
cp output/linux/amd64/$app-service cmd/$appname/
cd cmd/$app-service/
./$app-service run
```

## 清除k8s环境
```
su minikube
./dev-setup.sh -t destroy
```
