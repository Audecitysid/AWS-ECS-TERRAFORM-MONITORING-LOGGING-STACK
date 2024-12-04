Content-Type: multipart/mixed; boundary="==BOUNDARY=="
MIME-Version: 1.0

--==BOUNDARY==
Content-Type: text/cloud-boothook; charset="us-ascii"

# Set Docker daemon options
cloud-init-per once docker_options sed -i '/^OPTIONS/s/"$/ --storage-opt dm.basesize=25G"/' /etc/sysconfig/docker

--==BOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
sudo yum update
sudo yum install awscli -y
export AWS_REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}')
export HOST_NAME=$(aws ec2 describe-tags --region=$AWS_REGION --filters "Name=resource-id,Values=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)" "Name=key,Values=Name" --output=text | cut -f 5)
sudo hostnamectl set-hostname $HOST_NAME


echo 'ECS_CLUSTER=es-cluster' > /etc/ecs/ecs.config
sudo sysctl -w vm.max_map_count=262144
sudo sysctl -w fs.file-max=65536
sudo mkdir -p /usr/share/elasticsearch/data
sudo mkdir -p /usr/share/elasticsearch/config
sudo touch /usr/share/elasticsearch/config/elasticsearch.yml
cd /usr/share/elasticsearch/config

echo cluster.name: \"elasticsearch\" >> elasticsearch.yml
echo node.name: $HOST_NAME >> elasticsearch.yml
echo cluster.initial_master_nodes: aws-es-devops-dev-app-a, aws-es-devops-dev-app-b, aws-es-devops-dev-app-c >> elasticsearch.yml
echo bootstrap.memory_lock: true >> elasticsearch.yml
echo network.host: 0.0.0.0 >> elasticsearch.yml
echo cloud.node.auto_attributes: true >> elasticsearch.yml
echo discovery.seed_providers: ec2 >> elasticsearch.yml
echo network.publish_host: _ec2_>> elasticsearch.yml
echo transport.publish_host: _ec2_ >> elasticsearch.yml
echo transport.port: 9300 >> elasticsearch.yml
echo http.port: 9200 >> elasticsearch.yml
echo discovery.ec2.endpoint: ec2.eu-central-1.amazonaws.com >> elasticsearch.yml
echo discovery.ec2.availability_zones: us-east-1,eu-central-1b,eu-central-1c >> elasticsearch.yml
echo cluster.routing.allocation.awareness.attributes: aws_availability_zone >> elasticsearch.yml
echo discovery.ec2.tag.Elastic: \"node\" >> elasticsearch.yml
echo s3.client.default.endpoint: s3.eu-central-1.amazonaws.com >> elasticsearch.yml


sudo chown -R 1000.1000 /usr/share/elasticsearch/data/
sudo chown -R 1000.1000 /usr/share/elasticsearch/config/


--==BOUNDARY==--