#!/bin/bash
ECR_REPOSITORY=$1
IMAGE_TAG=$2
AWS_REGION=$3

aws ecr get-login-password --region $AWS_REGION | sudo docker login --username AWS --password-stdin $ECR_REPOSITORY
sudo docker pull ${ECR_REPOSITORY}:${IMAGE_TAG}
