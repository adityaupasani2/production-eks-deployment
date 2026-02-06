#!/bin/bash

###############################################################################
# Script: 01-install-prerequisites.sh
# Description: Install all required tools for EKS deployment
# Prerequisites: Ubuntu/Debian based system with sudo access
###############################################################################

set -e

echo "=========================================="
echo "Installing Prerequisites for EKS Project"
echo "=========================================="

# Update system packages
echo "Updating system packages..."
sudo apt-get update -y

# Install AWS CLI
echo "Installing AWS CLI..."
if ! command -v aws &> /dev/null; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf aws awscliv2.zip
    echo "AWS CLI installed successfully"
else
    echo "AWS CLI already installed"
fi

# Install kubectl
echo "Installing kubectl..."
if ! command -v kubectl &> /dev/null; then
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
    echo "kubectl installed successfully"
else
    echo "kubectl already installed"
fi

# Install eksctl
echo "Installing eksctl..."
if ! command -v eksctl &> /dev/null; then
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
    sudo mv /tmp/eksctl /usr/local/bin
    echo "eksctl installed successfully"
else
    echo "eksctl already installed"
fi

# Install Helm
echo "Installing Helm..."
if ! command -v helm &> /dev/null; then
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    echo "Helm installed successfully"
else
    echo "Helm already installed"
fi

# Verify installations
echo ""
echo "=========================================="
echo "Verifying Installations"
echo "=========================================="
echo "AWS CLI version:"
aws --version

echo ""
echo "kubectl version:"
kubectl version --client

echo ""
echo "eksctl version:"
eksctl version

echo ""
echo "Helm version:"
helm version

echo ""
echo "=========================================="
echo "✅ All prerequisites installed successfully!"
echo "=========================================="
echo ""
echo "Next step: Configure AWS CLI with 'aws configure'"