

AWS ECS ELK, Grafana, Prometheus, GlitchTip Deployment on ECS via Fargate and EC2 Exposed via ALB

Stage 1. Creating the Dynamodb table and TF state bucket

1. Navigate to terraform\dev\env.tfvars and give unique name for bucket 
2. replace the string "terraform-state-aws-es-devops-cloud-wizard-5" with your bucket name throughout the code
3. go to pre init directory (terraform\dev\pre-init\main.tf) 
3. run terraform init
4. run terraform apply -var-file ../env.tfvars


Stage 2: Building and Pushing Docker Images and replacing some URLs
          Prerequisites : 
           + Docker installed on your machine.
           + AWS CLI installed and configured with necessary access rights.

1. Before running the Terraform code, you need to create a repository in AWS ECR. This repository will store custom Docker images
   for elasticsearch and logstash.
   
   Create an ECR with name "ecs-docker-images" in the region us-east-1

   Guidance to create a repo can be found here:
   https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-create.html


2. docker file creation

	go to the directory docker-images\elastisearch\   and run   docker build -t ecs-elasticsearch .	
	go to the directory docker-images\logstash\       and run   docker build -t ecs-logstash .	 
	the above command will create the images
	note that the name for Elastic search image is ecs-elasticsearch and logstash image is ecs-logstash

3. push to ecr : (In the following commands replace the  233067124947 with your account id and run them for both logstash and elasticsearch)

   i) aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 233067124947.dkr.ecr.us-east-1.amazonaws.com

   ii) here we tag your images to the ECR so you can push the images
       docker tag ecs-elasticsearch:latest 233067124947.dkr.ecr.us-east-1.amazonaws.com/ecs-docker-images:ecs-elasticsearch

   iii) push the image to AWS ECR
   docker push 233067124947.dkr.ecr.us-east-1.amazonaws.com/ecs-docker-images:ecs-elasticsearch


4. In Your aws account create the key pair with name ecs-kp.pem . It will be used to access the elastic search ec2 instances so store it properly

5. Throughout the entire terraform code replace the string "233067124947" with your own account id


Stage 3: Running Terraform Code


step 1: Create Network Modules
Navigate to aws-es-devops/terraform/dev/network and run:

terraform init
terraform validate
terraform apply -var-file ../env.tfvars
This will create all the necessary network modules like VPC, subnets, etc.


Step 2: Create IAM Profiles for ECS
Navigate to aws-es-devops/terraform/dev/ecs-iam-profile and run:

terraform init
terraform validate
terraform apply -var-file ../env.tfvars

Step 3: Deploy ECS EC2 Cluster
Navigate to aws-es-devops/terraform/dev/ecs-ec2 and run:

terraform init
terraform validate
terraform apply -var-file ../env.tfvars

Step 4: Deploy ECS Cluster
Navigate to aws-es-devops/terraform/dev/ecs-cluster and run:

terraform init
terraform validate
terraform apply -var-file ../env.tfvars


Step 5: Deploy Kibana
Navigate to aws-es-devops/terraform/dev/Kib_dev and run:

terraform init
terraform validate
terraform apply -var-file ./env.tfvars


Step 6: Deploy logstash
Navigate to aws-es-devops/terraform/dev/logstash_dev and run:

terraform init
terraform validate
terraform apply -var-file ./env.tfvars

Step 7: Deploy grafana
Navigate to aws-es-devops/terraform/dev/grafana_dev and run:

terraform init
terraform validate
terraform apply -var-file ./env.tfvars


Step 8: Deploy promethius
Navigate to aws-es-devops/terraform/dev/promethius_dev and run:

terraform init
terraform validate
terraform apply -var-file ./env.tfvars



Step 9: Deploy glitchtip
Navigate to aws-es-devops/terraform/dev/glitchtip_dev and run:

terraform init
terraform validate
terraform apply -var-file ./env.tfvars




Stage 4: Deploying Services with a Bash Script 

Bash Script: deploy_services.sh

Make the script executable:

chmod +x deploy_services.sh

Run the script:

./deploy_services.sh

This script will deploy all the services (Kibana, Logstash, Grafana, Prometheus, and GlitchTip) by automatically running the necessary Terraform commands in each service directory.

Note: updating config of services
The variable values such as CPU, memory, and availability zones are stored in the ./env.tfvars file. The default values provided have been tested and are working, but you can update them as needed.

Note: Re-deploying Specific Services
If you need to delete and re-deploy any specific service, ensure that the ALB listeners, target groups, log groups, and cluster are deleted either via terraform destroy or manually. If you encounter an "Entity already exists" error, feel free to delete that entity manually.
