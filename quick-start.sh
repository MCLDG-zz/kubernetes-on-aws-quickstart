#!/usr/bin/env bash

#function to read properties from quick-start.properties
function getprop {
    grep "${1}" quick-start.properties|cut -d'=' -f2
}

region=$(getprop 'aws.region')
account=`aws sts get-caller-identity --output text --query 'Account'`

echo your region is ${region}
echo your account is ${account}

##install homebrew
#/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
#
##install Kops - used to create a K8s cluster
#brew update && brew install kops
#brew upgrade kops
#
##create ssh key, used by Kops. This will not overwrite an existing ssh key. If no ssh key exists, it will generate
##a new key with no passphrase
#cat /dev/zero | ssh-keygen -q -N ""
#
##enable versioning on your bucket
#aws s3api put-bucket-versioning \
#      --bucket $(getprop 's3.bucketname') \
#      --versioning-configuration Status=Enabled
#
#export KOPS_STATE_STORE=s3://$(getprop 's3.bucketname')
#
##create the K8s cluster
#echo creating the Kubernetes cluster
#if [$(getprop 'k8s.workernode.count') -lt 3]; then
#    masternodecount=1
#else
#    masternodecount=3
#fi
#
#kops create cluster $(getprop 'k8s.clustername').cluster.k8s.local \
#    --cloud aws \
#    --master-count $masternodecount \
#    --master-size $(getprop 'k8s.master.instancetype') \
#    --master-zones $(getprop 'az') \
#    --node-count $(getprop 'k8s.workernode.count') \
#    --node-size $(getprop 'k8s.node.instancetype') \
#    --zones $(getprop 'az') \
#
#kops update cluster mcdgk8s.cluster.k8s.local --yes
#
##validate the cluster has installed correctly
#echo it usually takes around 5 minutes to provision a K8s cluster. This script will keep checking until the cluster is created
#echo if you wish, you can check your EC2 console to see the creation status of the master and worker nodes
#while true; do
#    if kops validate cluster | grep -q 'Your cluster .* is ready'; then
#        echo K8s cluster installed correctly
#        break
#    else
#        echo K8s cluster installing...
#        sleep 10
#        continue
#    fi
#done
#
##install kubectl
#curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/darwin/amd64/kubectl
#chmod +x ./kubectl
#sudo mv ./kubectl /usr/local/bin/kubectl
#
##check that kubectl was installed and configured correctly
#kubectl cluster-info

./cluster-logging/quick-start.sh
./cluster-monitoring/quick-start.sh
./cluster-scaling/quick-start.sh
./cicd/quick-start.sh
./ingress-controllers/quick-start.sh
./secrets/quick-start.sh
./service-mesh/quick-start.sh
./distributed-tracing/quick-start.sh
./network-policy/quick-start.sh