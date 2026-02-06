#!/bin/bash

###############################################################################
# Script: 99-cleanup.sh
# Description: Delete all AWS resources to avoid charges
# WARNING: This will delete everything!
###############################################################################

set -e

# Configuration
CLUSTER_NAME="demo-cluster-2048"
REGION="us-east-1"
POLICY_NAME="AWSLoadBalancerControllerIAMPolicy"

echo "=========================================="
echo "⚠️  WARNING: Resource Cleanup"
echo "=========================================="
echo "This will DELETE the following:"
echo "  - 2048 game deployment"
echo "  - AWS Load Balancer Controller"
echo "  - EKS cluster: $CLUSTER_NAME"
echo "  - IAM roles and policies"
echo "  - VPC and networking resources"
echo ""
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Cleanup cancelled."
    exit 0
fi

echo ""
echo "=========================================="
echo "Step 1: Deleting 2048 Game Application"
echo "=========================================="
kubectl delete -f kubernetes/ingress.yaml --ignore-not-found=true
kubectl delete -f kubernetes/service.yaml --ignore-not-found=true
kubectl delete -f kubernetes/deployment.yaml --ignore-not-found=true
kubectl delete -f kubernetes/namespace.yaml --ignore-not-found=true

echo "Waiting for ALB to be deleted..."
sleep 30

echo ""
echo "=========================================="
echo "Step 2: Uninstalling ALB Controller"
echo "=========================================="
helm uninstall aws-load-balancer-controller -n kube-system --ignore-not-found || true
kubectl delete -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master" --ignore-not-found=true

echo ""
echo "=========================================="
echo "Step 3: Deleting IAM Service Account"
echo "=========================================="
eksctl delete iamserviceaccount \
    --cluster=$CLUSTER_NAME \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --region=$REGION || true

echo ""
echo "=========================================="
echo "Step 4: Deleting EKS Cluster"
echo "=========================================="
echo "This will take 10-15 minutes..."
eksctl delete cluster --name $CLUSTER_NAME --region $REGION

echo ""
echo "=========================================="
echo "Step 5: Deleting IAM Policy"
echo "=========================================="
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
aws iam delete-policy \
    --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/${POLICY_NAME} \
    2>/dev/null || echo "Policy already deleted or doesn't exist"

echo ""
echo "=========================================="
echo "✅ Cleanup completed successfully!"
echo "=========================================="
echo "All resources have been deleted."
echo "Please verify in AWS Console that no resources remain."
