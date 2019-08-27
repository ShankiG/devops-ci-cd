#!/bin/bash
# any future command that fails will exit the script
set -e
echo "------------------------------------------------------------"
echo "Node health check"
kubectl get nodes
echo "------------------------------------------------------------"
kubectl get svc -n environment-msproject
echo "------------------------------------------------------------"

echo "------------------------------------------------------------"
echo "deploy UAT microservices"
echo "kubectl apply -f environment-msproject_deployment.yml -n environment-msproject"
kubectl apply -f environment-msproject_deployment.yml -n environment-msproject
#echo "kubectl delete po --all -n environment-msproject"
#kubectl delete po --all -n environment-msproject

echo "------------------------------------------------------------"
echo "Pod health check"
echo "kubectl get po -o wide -n environment-msproject"
kubectl get po -o wide -n environment-msproject

echo "------------------------------------------------------------"
#echo " moving all yaml files to folder helm_Config "
#mv uat*.yml /home/ec2-user/helm_config/
