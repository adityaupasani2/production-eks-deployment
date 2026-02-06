#!/bin/bash

###############################################################################
# Script: 02-create-eks-cluster.sh
# Description: Create EKS cluster with Fargate profile
# Prerequisites: AWS CLI configured, eksctl installed
###############################################################################

set -e

# Configuration
CLUSTER_NAME="demo-cluster-2048"
REGION="us-east-1"
FARGATE_PROFILE_NAME="alb-sample-app"

echo "=========================================="
echo "Creating EKS Cluster"
echo "=========================================="
echo "Cluster Name: $CLUSTER_NAME"
echo "Region: $REGION"
echo "This will take 15-20 minutes..."
echo ""

# Create EKS cluster with Fargate
eksctl create cluster \
    --name $CLUSTER_NAME \
    --region $REGION \
    --fargate \
    --version 1.28

echo ""
echo "=========================================="
echo "Creating Fargate Profile for game-2048"
echo "=========================================="

# Create Fargate profile for game-2048 namespace
eksctl create fargateprofile \
    --cluster $CLUSTER_NAME \
    --region $REGION \
    --name $FARGATE_PROFILE_NAME \
    --namespace game-2048

echo ""
echo "=========================================="
echo "Updating kubeconfig"
echo "=========================================="

# Update kubeconfig
aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION

# Verify cluster access
echo ""
echo "Verifying cluster access..."
kubectl get nodes
kubectl get namespaces

echo ""
echo "=========================================="
echo "✅ EKS Cluster created successfully!"
echo "=========================================="
echo "Cluster Name: $CLUSTER_NAME"
echo "Region: $REGION"
echo ""
echo "Next step: Run ./scripts/03-configure-iam-oidc.sh"