#! /bin/bash

curuser=`whoami`
[ "x$curuser" != "xminikube" ] && echo "You shoud login as minikube~" && exit 0

LOG_FILE=/var/log/dev-quick-start.log
function usage() {
  echo " $1 -[ti]"
  echo "    -t action type [setup|destroy]"
  echo "    -i my host ip"
}

function info() {
  echo " <I> $1 ~" >> $LOG_FILE
}

while getopts 't:i:' OPT; do
  case $OPT in
    t) ACTION_TYPE=$OPTARG    ;;
    i) MY_HOSTIP=$OPTARG    ;;
    *) usage                  ;;
  esac
done

function add_minikube_user() {
  echo y | adduser minikube
  echo minikube:12345679 | chpasswd
  echo "minikube ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/minikube
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
#  minikube start

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
#  MYSQL_IP=`minikube service list | grep mysql | awk '{ print $8 }' | awk -F '//' '{ print $2 }' | awk -F ':' '{ print $1 }'`
#  MYSQL_PORT=`minikube service list | grep mysql | awk '{ print $8 }' | awk -F '//' '{ print $2 }' | awk -F ':' '{ print $2 }'`
#  sudo ./mysql-single/db-init.sh
}

function install_redis() {
  kubectl apply -f redis-cluster/01-redis-config -n kube-system
  kubectl apply -f redis-cluster/02-deployment-service.yaml -n kube-system
  check_pods_status
}

function install_apollo() {
  kubectl apply -f apollo-cluster/01-apollo-config-configmap.yaml -n kube-system
  kubectl apply -f apollo-cluster/02-apolloconfig-confgmap.yaml -n kube-system
  kubectl apply -f apollo-cluster/03-apollo-admin-configmap.yaml -n kube-system
  kubectl apply -f apollo-cluster/04-apollo-admin.yml -n kube-system
  kubectl apply -f apollo-cluster/05-apollo-portal-configmap.yaml -n kube-system
  kubectl apply -f apollo-cluster/06-apollo-portal.yml -n kube-system
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
  helm install rabbitmq -f values.service.yaml --namespace kube-system ./rabbitmq
  check_pods_status
  rabbitmqaddress=`minikube service list | grep 15672 | awk '{ print $8 }' | awk -F '//' '{ print $2 }'`
  sudo cp nginx-conf/rabbitmq.conf /etc/nginx/conf.d/rabbitmq.conf
  sudo sed -i "s/127.0.0.1/$rabbitmqaddress/g" /etc/nginx/conf.d/rabbitmq.conf
  sudo nginx -s reload
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
fi

if [ "x$ACTION_TYPE" == "xdestroy" ]; then
  minikube delete
  sudo rm /home/minikube/.minikube/ -rf
  sudo iptables -F
fi

if [ "x$ACTION_type" == "xinfo" ]; then
  echo "show k8s info"
fi
