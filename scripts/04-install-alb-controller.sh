#!/bin/bash

###############################################################################
# Script: 04-install-alb-controller.sh
# Description: Install AWS Load Balancer Controller using Helm
# Prerequisites: IAM OIDC provider configured, service account created
###############################################################################

set -e

# Configuration
CLUSTER_NAME="demo-cluster-2048"
REGION="us-east-1"

echo "=========================================="
echo "Installing AWS Load Balancer Controller"
echo "=========================================="

# Get VPC ID
echo "Getting VPC ID..."
VPC_ID=$(aws eks describe-cluster \
    --name $CLUSTER_NAME \
    --region $REGION \
    --query "cluster.resourcesVpcConfig.vpcId" \
    --output text)
echo "VPC ID: $VPC_ID"

# Add Helm repository
echo ""
echo "Adding eks-charts Helm repository..."
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# Install CRDs (Custom Resource Definitions)
echo ""
echo "Installing TargetGroupBinding CRDs..."
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"

# Install ALB controller
echo ""
echo "Installing AWS Load Balancer Controller..."
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName=$CLUSTER_NAME \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller \
    --set region=$REGION \
    --set vpcId=$VPC_ID

# Wait for deployment to be ready
echo ""
echo "Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s \
    deployment/aws-load-balancer-controller -n kube-system

# Verify installation
echo ""
echo "Verifying installation..."
kubectl get deployment -n kube-system aws-load-balancer-controller
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller

echo ""
echo "=========================================="
echo "✅ ALB Controller installed successfully!"
echo "=========================================="
echo "Controller: Running in kube-system namespace"
echo "VPC ID: $VPC_ID"
echo ""
echo "Next step: Run ./scripts/05-deploy-game.sh"