#!/bin/bash

###############################################################################
# Script: 03-configure-iam-oidc.sh
# Description: Configure IAM OIDC provider and create service account
# Prerequisites: EKS cluster already created
###############################################################################

set -e

# Configuration
CLUSTER_NAME="demo-cluster-2048"
REGION="us-east-1"
POLICY_NAME="AWSLoadBalancerControllerIAMPolicy"

echo "=========================================="
echo "Configuring IAM OIDC Provider"
echo "=========================================="

# Associate IAM OIDC provider
echo "Associating IAM OIDC provider with cluster..."
eksctl utils associate-iam-oidc-provider \
    --cluster=$CLUSTER_NAME \
    --region=$REGION \
    --approve

echo ""
echo "=========================================="
echo "Creating IAM Policy for ALB Controller"
echo "=========================================="

# Get AWS account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "AWS Account ID: $ACCOUNT_ID"

# Create IAM policy
echo "Creating IAM policy..."
aws iam create-policy \
    --policy-name $POLICY_NAME \
    --policy-document file://iam/iam-policy.json \
    2>/dev/null || echo "Policy already exists, skipping creation"

echo ""
echo "=========================================="
echo "Creating IAM Service Account"
echo "=========================================="

# Create IAM service account
eksctl create iamserviceaccount \
    --cluster=$CLUSTER_NAME \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --role-name AmazonEKSLoadBalancerControllerRole \
    --attach-policy-arn=arn:aws:iam::${ACCOUNT_ID}:policy/${POLICY_NAME} \
    --approve \
    --region=$REGION

echo ""
echo "Verifying service account..."
kubectl get sa aws-load-balancer-controller -n kube-system

echo ""
echo "=========================================="
echo "✅ IAM OIDC configured successfully!"
echo "=========================================="
echo "OIDC Provider: Associated"
echo "IAM Policy: $POLICY_NAME"
echo "Service Account: aws-load-balancer-controller"
echo ""
echo "Next step: Run ./scripts/04-install-alb-controller.sh"