#! /bin/bash

LOG_FILE=/var/log/dev-quick-start.log
function usage() {
  echo " $1 -[t]"
  echo "    -t action type [setup|destroy]"
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

function install_tools() {
#  sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
  sudo cp ./k8s-keyring/kubernetes-archive-keyring.gpg /usr/share/keyrings/kubernetes-archive-keyring.gpg
  sudo echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] http://mirrors.ustc.edu.cn/kubernetes/apt kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

  sudo apt-get update
  sudo apt install -y apt-transport-https gnupg2 curl docker.io kubectl git
  
  sudo curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
  sudo chmod +x minikube-linux-amd64
  sudo install ./minikube-linux-amd64 /usr/local/bin/minikube
}

function start_minikube() {
  sudo gpasswd -a minikube docker
  minikube start
#  all_proxy= minikube start --driver=docker --image-repository=registry.cn-hangzhou.aliyuncs.com/google_containers
  check_pods_status
}

function apply_nfs_server() {
  sudo apt install -y nfs-kernel-server
  sudo mkdir /var/share
  sudo chown nobody:nogroup /var/share/
  sudo sh -c "sed -i '/var\/share/d' /etc/exports"
  sudo sh -c "echo '/var/share *(rw,sync,no_subtree_check,no_root_squash)' >> /etc/exports"
  sudo systemctl restart nfs-server
  sudo cp nfs-provisioner/nfs-provisioner.yaml ./
  sudo sed -i "s/127.0.0.1/$MY_HOSTIP/g" nfs-provisioner.yaml
  kubectl apply -f nfs-provisioner.yaml -n kube-system
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
}

function install_nginx() {
  sudo apt install nginx -y
  consuladdress=`minikube service list | grep consul-ui | awk '{ print $8 }' | awk -F '//' '{ print $2 }'`
  sudo cp nginx-conf/consul.conf /etc/nginx/conf.d/consul.conf
  sudo sed -i "s/127.0.0.1/$consuladdress/g" /etc/nginx/conf.d/consul.conf
  sudo nginx -s reload
}

if [ "x$ACTION_TYPE" == "xsetup" ]; then
#  add_minikube_user
#  install_tools
#  start_minikube
#  apply_nfs_server
#  install_consul
  install_nginx
fi

if [ "x$ACTION_TYPE" == "xdestroy" ]; then
  minikube delete
  sudo rm /home/minikube/.minikube/ -rf
fi

if [ "x$ACTION_type" == "xinfo" ]; then
  echo "into"
fi
