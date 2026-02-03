#!/bin/bash
set -e

# 1. 解析来自 CodeDeploy 描述的 IMAGE_TAG
DESCRIPTION=$(aws deploy get-deployment --deployment-id $DEPLOYMENT_ID --query 'deploymentInfo.description' --output text)
IMAGE_TAG=$(echo $DESCRIPTION | cut -d'=' -f2)

# 2. 获取 AWS 信息
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
REGION="us-east-1"  # 如果不是这个区请修改
ECR_URL="$AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"
REPO_NAME="cool-admin-vue" 

# 3. 登录 ECR
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_URL

# 4. 拉取镜像
echo "Pulling frontend image: $ECR_URL/$REPO_NAME:$IMAGE_TAG"
docker pull $ECR_URL/$REPO_NAME:$IMAGE_TAG

# 5. 写入环境变量供 start.sh 使用
echo "VUE_IMAGE=$ECR_URL/$REPO_NAME:$IMAGE_TAG" > /opt/app/vue_env.file

# 6. 清理磁盘（t2.micro 空间有限，必须清理）
docker image prune -af