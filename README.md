# dev-quick-start

## 创建minikube用户
```
echo y | adduser minikube
echo minikube:12345679 | chpasswd
echo "minikube ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/minikube
```

## 快速搭建k8s测试环境
- 切换到minikube用户后执行命令 ./dev-setup.sh -t setup -i $MY_HOSTIP

## 创建app需要的vhost以及权限设置
```
appname=`cat cmd/*/*.viper.yaml | grep hostname | awk '{print $2}' | sed 's/"//g' | sed 's/\./-/g'`
kubectl exec -it --namespace kube-system rabbitmq-0 -- rabbitmqctl add_vhost $appname
kubectl exec -it --namespace kube-system rabbitmq-0 -- rabbitmqctl set_permissions -p $appname user ".*" ".*" ".*"
```

## apollo添加app对应的配置
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

## 在运行k8s集群的虚机上运行开发环境docker,构建app进行测试
```
docker run -d -e ENV_ENVIRONMENT_TARGET=developnment -e ENV_CONSUL_HOST=http://$MY_HOSTIP -e ENV_CONSUL_PORT=8500 --name devtest -v /sys/fs/cgroup:/sys/fs/cgroup:ro --privileged catwo/devtest
docker exec -it devtest /bin/bash
/etc/hosts添加以下内容
$MY_HOSTIP apollo-configservice.kube-system.svc.cluster.local
$MY_HOSTIP rabbitmq.kube-system.svc.cluster.local

开始构建你的app
git clone https://github.com/NpoolPlatform/$app.git
```
