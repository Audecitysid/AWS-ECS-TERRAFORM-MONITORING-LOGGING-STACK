#!/bin/bash

# Function to deploy a service
deploy_service() {
  local service_dir="$1"
  

  echo "Deploying service in $service_dir..."

  cd "$service_dir" || exit

  echo "Initializing Terraform..."
  terraform init

  echo "Validating Terraform configuration..."
  terraform validate

  echo "Applying Terraform configuration..."
  terraform apply 

  if [ $? -eq 0 ]; then
    echo "Deployment of $service_dir completed successfully."
  else
    echo "Deployment of $service_dir failed."
    exit 1
  fi

  cd - || exit
}

# List of services to deploy
services=(
  "aws-es-devops/terraform/dev/kib_dev"
  "aws-es-devops/terraform/dev/logstash_dev"
  "aws-es-devops/terraform/dev/grafana_dev"
  "aws-es-devops/terraform/dev/prometheus_dev"
  "aws-es-devops/terraform/dev/glitchtip_dev"
)

# Deploy each service
for service in "${services[@]}"; do
  deploy_service "$service" 
done

echo "All services have been deployed."
