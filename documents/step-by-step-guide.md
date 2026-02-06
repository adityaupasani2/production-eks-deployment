# 📖 Step-by-Step Deployment Guide

This guide provides detailed instructions for deploying the 2048 game on AWS EKS.

## Table of Contents

1. [Pre-Deployment Checklist](#pre-deployment-checklist)
2. [Detailed Step-by-Step Instructions](#detailed-step-by-step-instructions)
3. [Verification Steps](#verification-steps)
4. [Common Issues and Solutions](#common-issues-and-solutions)

---

## Pre-Deployment Checklist

Before starting, ensure you have:

- [ ] AWS Account with appropriate permissions
- [ ] AWS Access Key ID and Secret Access Key
- [ ] Ubuntu/Debian based Linux system (or EC2 instance)
- [ ] Minimum 2GB RAM and 10GB disk space
- [ ] Internet connectivity
- [ ] Basic knowledge of AWS, Kubernetes, and Linux commands

---

## Detailed Step-by-Step Instructions

### Phase 1: Environment Setup

#### Step 1.1: Launch EC2 Instance (Optional)

If you don't have a local Linux machine:
```bash
# Launch t2.medium or larger instance with Ubuntu 22.04
# Ensure security group allows:
# - Port 22 (SSH)
# - Port 80 (HTTP)

# SSH into instance
ssh -i your-key.pem ubuntu@<instance-ip>
```

#### Step 1.2: Install Prerequisites
```bash
# Clone the repository
git clone https://github.com/adityaupasani2/production-eks-deployment.git
cd production-eks-deployment

# Run installation script
chmod +x scripts/*.sh
./scripts/01-install-prerequisites.sh
```

**What this does:**
- Updates system packages
- Installs AWS CLI v2
- Installs kubectl (Kubernetes CLI)
- Installs eksctl (EKS management tool)
- Installs Helm (Kubernetes package manager)

**Expected output:**
```
✅ All prerequisites installed successfully!
AWS CLI version: aws-cli/2.x.x
kubectl version: v1.28.x
eksctl version: 0.150.0
Helm version: v3.x.x
```

#### Step 1.3: Configure AWS CLI
```bash
aws configure
```

Enter your credentials:
- **AWS Access Key ID**: [Your access key]
- **AWS Secret Access Key**: [Your secret key]
- **Default region name**: `us-east-1`
- **Default output format**: `json`

**Verify configuration:**
```bash
aws sts get-caller-identity
```

---

### Phase 2: EKS Cluster Creation

#### Step 2.1: Create EKS Cluster
```bash
./scripts/02-create-eks-cluster.sh
```

**What this does:**
- Creates EKS control plane (Multi-AZ)
- Creates VPC with public and private subnets
- Sets up Internet Gateway and NAT Gateways
- Creates Fargate profile for `game-2048` namespace
- Updates kubeconfig for kubectl access

**Duration:** 15-20 minutes

**Expected output:**
```
✅ EKS Cluster created successfully!
Cluster Name: demo-cluster-2048
Region: us-east-1
```

#### Step 2.2: Verify Cluster
```bash
# Check nodes
kubectl get nodes

# Check namespaces
kubectl get namespaces

# Check cluster info
kubectl cluster-info
```

---

### Phase 3: IAM Configuration

#### Step 3.1: Associate OIDC Provider
```bash
./scripts/03-configure-iam-oidc.sh
```

**What this does:**
- Associates IAM OIDC identity provider with your cluster
- Creates IAM policy `AWSLoadBalancerControllerIAMPolicy`
- Creates IAM service account for ALB controller
- Links IAM role to Kubernetes service account (IRSA)

**Why OIDC?**
Kubernetes pods need to make AWS API calls to create load balancers. OIDC allows pods to assume IAM roles securely without hardcoding credentials.

**Verification:**
```bash
# Check service account
kubectl get sa aws-load-balancer-controller -n kube-system

# Verify IAM role annotation
kubectl describe sa aws-load-balancer-controller -n kube-system
```

---

### Phase 4: ALB Controller Installation

#### Step 4.1: Install AWS Load Balancer Controller
```bash
./scripts/04-install-alb-controller.sh
```

**What this does:**
- Adds AWS EKS Helm repository
- Installs Custom Resource Definitions (CRDs)
- Deploys ALB controller as a pod in `kube-system`
- Configures controller with cluster and VPC details

**Verification:**
```bash
# Check deployment
kubectl get deployment -n kube-system aws-load-balancer-controller

# Check pods
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller

# View logs
kubectl logs -n kube-system deployment/aws-load-balancer-controller
```

---

### Phase 5: Deploy 2048 Game

#### Step 5.1: Deploy Application
```bash
./scripts/05-deploy-game.sh
```

**What this does:**
1. Creates `game-2048` namespace
2. Deploys 3 replicas of 2048 game
3. Creates NodePort service
4. Creates Ingress resource (triggers ALB creation)
5. Waits for ALB to be provisioned

**Duration:** 2-3 minutes

#### Step 5.2: Monitor Deployment
```bash
# Watch pods come up
kubectl get pods -n game-2048 -w

# Check deployment status
kubectl get deployment -n game-2048

# Check service
kubectl get svc -n game-2048

# Check ingress
kubectl get ingress -n game-2048
```

#### Step 5.3: Get Game URL
```bash
kubectl get ingress ingress-2048 -n game-2048 -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

#### Step 5.4: Access the Game

1. Copy the ALB URL from above
2. Open in your browser: `http://[ALB-URL]`
3. **Play the game!** 🎮

---

## Verification Steps

### Verify All Components
```bash
# 1. Check EKS cluster
eksctl get cluster --region us-east-1

# 2. Check all pods in all namespaces
kubectl get pods -A

# 3. Check game-2048 namespace
kubectl get all -n game-2048

# 4. Check ALB Controller
kubectl get deployment -n kube-system aws-load-balancer-controller

# 5. Check ALB in AWS Console
aws elbv2 describe-load-balancers --region us-east-1
```

---

## Common Issues and Solutions

### Issue 1: Pods Stuck in Pending

**Symptoms:**
```bash
kubectl get pods -n game-2048
# Shows: STATUS = Pending
```

**Solution:**
```bash
# Check events
kubectl describe pod <pod-name> -n game-2048

# Verify Fargate profile
eksctl get fargateprofile --cluster demo-cluster-2048 --region us-east-1
```

### Issue 2: Ingress Has No Address

**Symptoms:**
```bash
kubectl get ingress -n game-2048
# ADDRESS field is empty
```

**Solution:**
```bash
# 1. Check ALB controller logs
kubectl logs -n kube-system deployment/aws-load-balancer-controller

# 2. Verify IAM permissions
kubectl describe sa aws-load-balancer-controller -n kube-system

# 3. Check ingress events
kubectl describe ingress ingress-2048 -n game-2048
```

### Issue 3: Cannot Access Game URL

**Symptoms:**
- ALB URL returns timeout or connection refused

**Solution:**
```bash
# 1. Wait 2-3 minutes for ALB to provision

# 2. Check target health in AWS Console

# 3. Verify pods are running
kubectl get pods -n game-2048

# 4. Check service endpoints
kubectl get endpoints -n game-2048
```

### Issue 4: ALB Not Created (Account Restriction)

**Symptoms:**
```
OperationNotPermitted: This AWS account currently does not support creating load balancers
```

**Solution:**
```bash
# Option 1: Check service quotas
aws service-quotas get-service-quota \
    --service-code elasticloadbalancing \
    --quota-code L-53DA6B97 \
    --region us-east-1

# Option 2: Try different region
# Edit scripts and change REGION="us-west-2"

# Option 3: Contact AWS Support for account activation
```

---

## Clean Up

**IMPORTANT:** Delete all resources to avoid AWS charges:
```bash
./scripts/99-cleanup.sh
```

This will delete:
- 2048 game deployment
- ALB and target groups
- ALB Controller
- EKS cluster
- VPC and networking
- IAM roles and policies

**Verify deletion in AWS Console.**

---

**Congratulations!** You've successfully deployed a containerized application on AWS EKS! 🎉