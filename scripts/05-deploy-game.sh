#!/bin/bash

###############################################################################
# Script: 05-deploy-game.sh
# Description: Deploy 2048 game application to EKS
# Prerequisites: ALB controller installed
###############################################################################

set -e

echo "=========================================="
echo "Deploying 2048 Game Application"
echo "=========================================="

# Apply Kubernetes manifests
echo "Creating namespace..."
kubectl apply -f kubernetes/namespace.yaml

echo ""
echo "Deploying 2048 game..."
kubectl apply -f kubernetes/deployment.yaml

echo ""
echo "Creating service..."
kubectl apply -f kubernetes/service.yaml

echo ""
echo "Creating ingress..."
kubectl apply -f kubernetes/ingress.yaml

# Wait for deployment to be ready
echo ""
echo "Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s \
    deployment/deployment-2048 -n game-2048

# Wait for ingress to get address
echo ""
echo "Waiting for ALB to be provisioned (this may take 2-3 minutes)..."
for i in {1..60}; do
    ADDRESS=$(kubectl get ingress ingress-2048 -n game-2048 -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")
    if [ ! -z "$ADDRESS" ]; then
        break
    fi
    echo "Waiting... ($i/60)"
    sleep 5
done

# Display deployment status
echo ""
echo "=========================================="
echo "Deployment Status"
echo "=========================================="
echo ""
echo "Namespace:"
kubectl get namespace game-2048

echo ""
echo "Pods:"
kubectl get pods -n game-2048

echo ""
echo "Service:"
kubectl get service -n game-2048

echo ""
echo "Ingress:"
kubectl get ingress -n game-2048

# Get ALB URL
echo ""
echo "=========================================="
echo "✅ 2048 Game deployed successfully!"
echo "=========================================="
ALB_URL=$(kubectl get ingress ingress-2048 -n game-2048 -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

if [ ! -z "$ALB_URL" ]; then
    echo ""
    echo "🎮 Access the game at:"
    echo "   http://$ALB_URL"
    echo ""
    echo "Note: It may take 2-3 minutes for the ALB to become fully operational."
else
    echo ""
    echo "⚠️  ALB URL not yet available. Check again in a few minutes with:"
    echo "   kubectl get ingress -n game-2048"
fi

echo ""
echo "To view logs:"
echo "   kubectl logs -f deployment/deployment-2048 -n game-2048"