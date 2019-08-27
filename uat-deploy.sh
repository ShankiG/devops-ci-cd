#!/bin/bash
# any future command that fails will exit the script
'which ssh-agent || ( apt-get update -y && apt-get install openssh-client -y )'
npm install
source variable
echo $IMAGE_TAG

mv deploy/deployment.yml deploy/uat-"$msproject"_deployment.yml
mv deploy/service.yml deploy/uat-"$msproject"_service.yml

cat deploy/uat-"$msproject"_deployment.yml  
sed -i -e 's|imagetag|'$IMAGE_TAG'|g' deploy/uat-"$msproject"_deployment.yml
sed -i -e 's|msproject|'$msproject'|g' deploy/uat-"$msproject"_deployment.yml
sed -i -e 's|portno|'$uatportno'|g' deploy/uat-"$msproject"_deployment.yml
sed -i -e 's|environment|'uat'|g' deploy/uat-"$msproject"_deployment.yml

sed -i -e 's|cpurequest|'$cpurequest'|g' deploy/uat-"$msproject"_deployment.yml
sed -i -e 's|memoryrequest|'$memoryrequest'|g' deploy/uat-"$msproject"_deployment.yml
sed -i -e 's|cpulimit|'$cpulimit'|g' deploy/uat-"$msproject"_deployment.yml
sed -i -e 's|memorylimit|'$memorylimit'|g' deploy/uat-"$msproject"_deployment.yml

sed -i -e 's|msproject|'$msproject'|g' deploy/uat-"$msproject"_service.yml
sed -i -e 's|portno|'$uatportno'|g' deploy/uat-"$msproject"_service.yml  
sed -i -e 's|environment|'uat'|g' deploy/uat-"$msproject"_service.yml  
sed -i -e 's|msproject|'$msproject'|g' deploy/update.sh
sed -i -e 's|environment|'uat'|g' deploy/update.sh

echo " ------------------------------------"
cat deploy/uat-"$msproject"_deployment.yml
echo " ------------------------------------"
cat deploy/uat-"$msproject"_service.yml
echo " ------------------------------------"
cat deploy/update.sh
echo " ------------------------------------"

set -e
eval $(ssh-agent -s)
echo "$UAT_JUMPHOST" | tr -d '\r' | ssh-add - > /dev/null
echo " ------------------ "
echo $IMAGE_TAG
echo " -------------------------------"

#ssh-keygen -R hostname
# disable the host key checking.
chmod 777 ./deploy/update.sh
chmod 777 ./deploy/disableHostKeyChecking.sh
./deploy/disableHostKeyChecking.sh
ls -ltr
# we have already setup the DEPLOYER_SERVER in our gitlab settings which is a
# comma seperated values of ip addresses.

UAT_DEPLOY_SERVERS=$UAT_DEPLOY_SERVERS
ALL_SERVERS=(${UAT_DEPLOY_SERVERS//,/ })
echo "ALL_SERVERS ${ALL_SERVERS}"

for server in "${ALL_SERVERS[@]}"
do
  echo "deploying to ${server}"
  scp ./deploy/uat-"$msproject"_deployment.yml ec2-user@"${server}":~/.
  echo "added uat-"$msproject"_deployment.yml"
  scp ./deploy/uat-"$msproject"_service.yml ec2-user@"${server}":~/.
  echo "added uat-"$msproject"_service.yml"
  ssh ec2-user@"${server}" 'bash -s' < ./deploy/update.sh
done
