#! /bin/bash

curuser=`whoami`
[ "x$curuser" != "xminikube" ] && echo "You shoud login as minikube~" && exit 0

function usage() {
  echo " $1 -[tiHD]"
  echo "    -t action type [setup|destroy|config]"
  echo "    -i my host ip"
  echo "    -H appid[service-sample-npool-top]"
  echo "    -D database[service_sample]"
}

function info() {
  echo " <I> $1 ~"
}

function error() {
  echo " <E> $1 ~"
  exit 1
}

while getopts 't:i:H:D:A:' OPT; do
  case $OPT in
    t) ACTION_TYPE=$OPTARG    ;;
    i) MY_HOSTIP=$OPTARG      ;;
    H) APP_HOST=$OPTARG       ;;
    D) APP_DATABASE=$OPTARG   ;;
    A) ALL_PROXY=$OPTARG      ;;
    *) usage                  ;;
  esac
done

function add_minikube_user() {
  echo y | adduser minikube
  echo minikube:12345679 | chpasswd
  echo "minikube ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/minikube
  gpasswd -a minikube docker
}

function check_pods_status() {
  while true; do
    sleep 5
    kubectl get pods -A | awk '{ print $4 }' | grep -v STATUS | grep -v Running
    [ 0 -eq $? ] && sleep 30 && continue
    break
  done
}

function check_consul_server() {
  while true; do
    sleep 5
    all_proxy= curl http://$MY_HOSTIP:8500/v1/agent/services
    [ ! 0 -eq $? ] && sleep 30 && continue
    break
  done
}


function install_tools() {
#  sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
  sudo cp ./k8s-keyring/kubernetes-archive-keyring.gpg /usr/share/keyrings/kubernetes-archive-keyring.gpg
  sudo echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] http://mirrors.ustc.edu.cn/kubernetes/apt kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

  sudo apt-get update
  sudo apt install -y apt-transport-https gnupg2 curl docker.io kubectl git mysql-client redis-tools nginx
  
  ls /usr/local/bin/ | grep minikube
  if [ ! 0 -eq $? ]; then
    sudo curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo chmod +x minikube-linux-amd64
    sudo install ./minikube-linux-amd64 /usr/local/bin/minikube
  fi
}

function start_minikube() {
  sudo gpasswd -a minikube docker
  minikube start --driver=docker --image-repository=registry.cn-hangzhou.aliyuncs.com/google_containers --extra-config=apiserver.service-node-port-range=3000-60000

  check_pods_status
}

function install_consul() {
#  sudo curl -L -o helm-v3.2.4-linux-amd64.tar.gz https://file.choerodon.com.cn/kubernetes-helm/v3.2.4/helm-v3.2.4-linux-amd64.tar.gz
#  sudo tar xvf helm-v3.2.4-linux-amd64.tar.gz
#  sudo cp linux-amd64/helm /usr/local/bin/
  sudo cp ./helm-tools/helm /usr/local/bin/
  helm repo add hashicorp https://helm.releases.hashicorp.com
  helm install -f consul-cluster/01-config.yaml consul hashicorp/consul -n kube-system
  check_pods_status
  kubectl apply -f consul-cluster/02-counting.yaml -n kube-system
  check_pods_status
  kubectl apply -f consul-cluster/03-dashboard.yaml -n kube-system
  check_pods_status
  consuladdress=`minikube service list | grep consul-ui | awk '{ print $8 }' | awk -F '//' '{ print $2 }'`
  sudo cp nginx-conf/consul.conf /etc/nginx/conf.d/consul.conf
  sudo sed -i "s/127.0.0.1/$consuladdress/g" /etc/nginx/conf.d/consul.conf
  sudo nginx -s reload
  check_consul_server
}

function install_mysql() {
  kubectl create secret generic mysql-password-secret --from-literal=rootpassword=12345679 -n kube-system
  kubectl apply -k environment-definitions/ -n kube-system
  kubectl apply -f mysql-single/01-mysql-configmap.yaml -n kube-system
  kubectl apply -f mysql-single/02-pv-pvc.yaml -n kube-system
  kubectl apply -f mysql-single/03-deployment-service.yaml -n kube-system
  check_pods_status
}

function install_redis() {
  export REDIS_PASSWORD=12345679
  envsubst < redis-cluster/secret.yaml | kubectl apply -f -
  kubectl apply -f redis-cluster/01-configmap.yaml -n kube-system
  kubectl apply -f redis-cluster/02-headless-service.yaml -n kube-system
  kubectl apply -f redis-cluster/03-statefulset.yaml -n kube-system
  check_pods_status
}

function install_apollo() {
  helm install apollo-service --namespace kube-system -f apollo-cluster/values.service.yaml apollo-cluster/chart-service
  helm install apollo-portal --namespace kube-system -f apollo-cluster/values.portal.yaml apollo-cluster//chart-portal
  check_pods_status
  apolloportaladdress=`minikube service list | grep apollo-portal | awk '{ print $8 }' | awk -F '//' '{ print $2 }'`
  sudo cp nginx-conf/apollo-portal.conf /etc/nginx/conf.d/apollo-portal.conf
  sudo sed -i "s/127.0.0.1/$apolloportaladdress/g" /etc/nginx/conf.d/apollo-portal.conf
  apolloadminaddress=`minikube service list | grep apollo-admin | awk '{ print $8 }' | awk -F '//' '{ print $2 }'`
  sudo cp nginx-conf/apollo-adminservice.conf /etc/nginx/conf.d/apollo-adminservice.conf
  sudo sed -i "s/127.0.0.1/$apolloadminaddress/g" /etc/nginx/conf.d/apollo-adminservice.conf
  apolloconfigaddress=`minikube service list | grep apollo-config | awk '{ print $8 }' | awk -F '//' '{ print $2 }'`
  sudo cp nginx-conf/apollo-configservice.conf /etc/nginx/conf.d/apollo-configservice.conf
  sudo sed -i "s/127.0.0.1/$apolloconfigaddress/g" /etc/nginx/conf.d/apollo-configservice.conf
  sudo nginx -s reload
}

function install_rabbitmq() {
  export RABBITMQ_PASSWORD=12345679
  envsubst < rabbitmq-cluster/secret.yaml | kubectl apply -f -
  helm install rabbitmq -f rabbitmq-cluster/values.service.yaml --namespace kube-system rabbitmq-cluster/rabbitmq
  check_pods_status
  rabbitmqaddress=`minikube service list | grep 15672 | awk '{ print $6 }' | awk -F '//' '{ print $2 }'`
  sudo cp nginx-conf/rabbitmq.conf /etc/nginx/conf.d/rabbitmq.conf
  sudo sed -i "s/127.0.0.1/$rabbitmqaddress/g" /etc/nginx/conf.d/rabbitmq.conf
  sudo nginx -s reload

#  sudo cp nginx-conf/nginx.conf /etc/nginx/nginx.conf
#  sudo mkdir -p /etc/nginx/stream.conf.d
#  sudo cp nginx-conf/rabbitmq-amqp.conf /etc/nginx/stream.conf.d/rabbitmq-amqp.conf
#  rabbitmqstreamaddress=`minikube service list | grep -w 5672 | awk '{ print $8 }' | awk -F '//' '{ print $2 }'`
#  sudo sed -i "s/127.0.0.1/$rabbitmqstreamaddress/g" /etc/nginx/stream.conf.d/rabbitmq-amqp.conf
}

function run_devtest() {
  kubectl apply -f dev-docker/01-service-sample.yaml -n kube-system
}

function config_apollo() {
  APP_ID="89089012783789789719823798127398"
  ENVIRONMENT="development"
  sudo rm apollo-base-config/ -rf
  sudo all_proxy=$ALL_PROXY git clone https://github.com/NpoolPlatform/apollo-base-config.git
  mysqlname=`kubectl get pods -A | grep mysql | awk '{print $2}'`
  sudo sed -i "s/mysql-0/$mysqlname/g" ./apollo-base-config/*
  if [ ! "x" == "x$APP_HOST" ]; then
    kubectl -n kube-system exec $mysqlname -- mysql -h 127.0.0.1 -uroot -p12345679 -P3306 -e "create database if not exists $APP_DATABASE;"
    kubectl exec -it --namespace kube-system rabbitmq-0 -- rabbitmqctl add_vhost $APP_HOST
    kubectl exec -it --namespace kube-system rabbitmq-0 -- rabbitmqctl set_permissions -p $APP_HOST user ".*" ".*" ".*"
    ./apollo-base-config/apollo-base-config.sh $APP_ID $ENVIRONMENT $APP_HOST
    ./apollo-base-config/apollo-item-config.sh $APP_ID $ENVIRONMENT $APP_HOST database_name $APP_DATABASE
  fi
  # add namespace
  ./apollo-base-config/apollo-appid-config.sh $APP_ID $ENVIRONMENT
  ./apollo-base-config/apollo-base-config.sh $APP_ID $ENVIRONMENT mysql-npool-top
  ./apollo-base-config/apollo-base-config.sh $APP_ID $ENVIRONMENT redis-npool-top
  ./apollo-base-config/apollo-base-config.sh $APP_ID $ENVIRONMENT rabbitmq-npool-top
  # add item
  ./apollo-base-config/apollo-item-config.sh $APP_ID $ENVIRONMENT mysql-npool-top username root
  ./apollo-base-config/apollo-item-config.sh $APP_ID $ENVIRONMENT mysql-npool-top password 12345679
  ./apollo-base-config/apollo-item-config.sh $APP_ID $ENVIRONMENT redis-npool-top username root
  ./apollo-base-config/apollo-item-config.sh $APP_ID $ENVIRONMENT redis-npool-top password 12345679
  ./apollo-base-config/apollo-item-config.sh $APP_ID $ENVIRONMENT rabbitmq-npool-top username user
  ./apollo-base-config/apollo-item-config.sh $APP_ID $ENVIRONMENT rabbitmq-npool-top password 12345679
}

if [ "x$ACTION_TYPE" == "xsetup" ]; then
#  add_minikube_user
  install_tools
  start_minikube
  install_consul
  install_mysql
  install_redis
  install_apollo
  install_rabbitmq
  run_devtest
  config_apollo
fi

if [ "x$ACTION_TYPE" == "xdestroy" ]; then
  type minikube > /dev/null 2>&1
  [ 0 -eq $? ] && minikube delete > /dev/null 2>&1
  sudo rm /home/minikube/.minikube/ -rf
  sudo iptables -F
fi

if [ "x$ACTION_TYPE" == "xinfo" ]; then
  echo "CONSUL: http://\$NODEIP:8500"
  echo "APOLLO: http://\$NODEIP:8070 apollp/admin"
  echo "RABBITMQ: http://\$NODEIP:15672 user/12345679" 
fi

if [ "x$ACTION_TYPE" == "xconfig" ]; then
  [ "x" == "x$APP_HOST" ] && error "app host is must"
  config_apollo
fi
