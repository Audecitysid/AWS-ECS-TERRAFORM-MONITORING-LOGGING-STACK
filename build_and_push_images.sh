#!/bin/bash

# Variables
REGION="us-east-1"  # Replace with your AWS region
AWS_ACCOUNT_ID="123456789012"  # Replace with your AWS account ID
ECR_REPO_ES="my-elasticsearch-repo"  # ECR Repository URL for Elasticsearch
ECR_REPO_LOGSTASH="my-elasticsearch-repo"  # ECR Repository URL for Logstash

# Check if the correct number of arguments is passed
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <ECR_REPO_ES_URL> <ECR_REPO_LOGSTASH_URL>"
  exit 1
fi

# Function to build and push Docker images
build_and_push() {
  local service_dir="$1"
  local image_name="$2"
  local ecr_repo_url="$3"

  echo "Building Docker image for $image_name..."
  cd "$service_dir" || exit
  docker build -t "$image_name" .

  echo "Tagging Docker image..."
  docker tag "$image_name:latest" "$ecr_repo_url:latest"

  echo "Pushing Docker image to ECR..."
  aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"
  docker push "$ecr_repo_url:latest"
}

# Build and push Elasticsearch image
build_and_push "elasticsearch" "my-elasticsearch" "$ECR_REPO_ES"

# Build and push Logstash image
build_and_push "logstash" "my-logstash" "$ECR_REPO_LOGSTASH"

echo "Docker images successfully pushed to ECR."