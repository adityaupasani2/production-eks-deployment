# 🎮 Production EKS Deployment - 2048 Game on AWS

Deploy a production-grade 2048 game application on Amazon EKS with Application Load Balancer Ingress Controller, demonstrating real-world Kubernetes and AWS cloud-native architecture.

![AWS](https://img.shields.io/badge/AWS-EKS-orange?style=for-the-badge&logo=amazon-aws)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Technologies Used](#technologies-used)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Detailed Setup](#detailed-setup)
- [Troubleshooting](#troubleshooting)
- [Project Structure](#project-structure)
- [Learning Outcomes](#learning-outcomes)
- [Contributing](#contributing)
- [License](#license)

## 🎯 Project Overview

This project showcases a complete production-ready deployment of the 2048 game on AWS EKS (Elastic Kubernetes Service). It demonstrates enterprise-grade DevOps practices including:

- **Infrastructure as Code** with automated bash scripts
- **Container orchestration** using Kubernetes
- **Managed Kubernetes** with AWS EKS
- **Load balancing** via AWS Application Load Balancer
- **Security best practices** with IAM OIDC integration
- **High availability** with multi-AZ deployment
- **Documentation-first** approach

### What Makes This Production-Grade?

✅ **Automated deployment** scripts for reproducibility  
✅ **Health checks** and readiness probes  
✅ **Resource limits** and requests configured  
✅ **Multi-replica deployment** for high availability  
✅ **IAM roles for service accounts** for secure AWS access  
✅ **Proper networking** with VPC, subnets, and security groups  
✅ **Clean-up automation** to manage costs  

## 🏗️ Architecture
```
User Browser
    ↓
Internet Gateway
    ↓
Application Load Balancer (ALB)
    ↓
Kubernetes Ingress (ingress-2048)
    ↓
Kubernetes Service (service-2048)
    ↓
2048 Game Pods (3 replicas across multiple AZs)
```

### Infrastructure Components

- **EKS Control Plane**: Managed by AWS across multiple Availability Zones
- **Worker Nodes**: Fargate or EC2 instances in private subnets
- **VPC**: Spanning 2 Availability Zones with public and private subnets
- **ALB**: Automatically provisioned by AWS Load Balancer Controller
- IAM OIDC**: Enables pods to securely assume IAM roles
- **NAT Gateways**: For private subnet internet access

## 🛠️ Technologies Used

| Technology | Purpose |
|------------|---------|
| **AWS EKS** | Managed Kubernetes service |
| **Kubernetes** | Container orchestration |
| **Docker** | Containerization |
| **AWS ALB** | Application load balancing |
| **AWS IAM** | Identity and access management |
| **Helm** | Kubernetes package manager |
| **eksctl** | EKS cluster management CLI |
| **kubectl** | Kubernetes CLI |
| **Bash** | Automation scripting |

## 🔧 Prerequisites

### Required Tools

- AWS Account with appropriate permissions
- AWS CLI (v2.x or later)
- kubectl (v1.28 or later)
- eksctl (v0.150.0 or later)
- Helm (v3.x or later)
- Git

### AWS Permissions Required

Your IAM user/role needs permissions for:
- EKS cluster creation and management
- VPC and networking resources (subnets, security groups, IGW, NAT)
- IAM role creation and policy attachment
- EC2 or Fargate resource provisioning
- Elastic Load Balancing (ALB creation)

### System Requirements

- Linux/MacOS or WSL on Windows
- Minimum 2GB RAM
- 10GB free disk space
- Internet connectivity

## 🚀 Quick Start
```bash
# 1. Clone the repository
git clone https://github.com/adityaupasani2/production-eks-deployment.git
cd production-eks-deployment

# 2. Make scripts executable
chmod +x scripts/*.sh

# 3. Install prerequisites
./scripts/01-install-prerequisites.sh

# 4. Configure AWS CLI
aws configure

# 5. Create EKS cluster (takes 15-20 minutes)
./scripts/02-create-eks-cluster.sh

# 6. Configure IAM OIDC
./scripts/03-configure-iam-oidc.sh

# 7. Install ALB Controller
./scripts/04-install-alb-controller.sh

# 8. Deploy the 2048 game
./scripts/05-deploy-game.sh

# 9. Get the game URL
kubectl get ingress -n game-2048

# 10. Play the game! 🎮
# Open the ALB URL in your browser
```

## 📖 Detailed Setup

For comprehensive step-by-step instructions, see [Step-by-Step Guide](docs/step-by-step-guide.md).

### Phase 1: Environment Setup
1. Install required tools (AWS CLI, kubectl, eksctl, Helm)
2. Configure AWS credentials
3. Verify installations

### Phase 2: EKS Cluster Creation
1. Create EKS cluster with control plane
2. Set up VPC with networking components
3. Create Fargate profile or EC2 node group
4. Update kubeconfig

### Phase 3: IAM Configuration
1. Associate IAM OIDC provider
2. Create IAM policy for ALB controller
3. Create IAM service account
4. Link IAM role to Kubernetes service account

### Phase 4: ALB Controller Installation
1. Add Helm repository
2. Install Custom Resource Definitions (CRDs)
3. Deploy ALB controller
4. Verify installation

### Phase 5: Application Deployment
1. Create game-2048 namespace
2. Deploy 2048 game application
3. Create Kubernetes service
4. Create Ingress resource (triggers ALB creation)
5. Access the game via ALB URL

## 🔍 Troubleshooting

### Common Issues

#### Issue: ALB Not Created

**Symptoms:** Ingress has no ADDRESS field

**Solutions:**
```bash
# Check ALB controller logs
kubectl logs -n kube-system deployment/aws-load-balancer-controller

# Verify subnet tags
aws ec2 describe-subnets --filters "Name=vpc-id,Values=<VPC_ID>"

# Check IAM permissions
kubectl describe sa aws-load-balancer-controller -n kube-system
```

#### Issue: Pods in Pending State

**Solutions:**
```bash
# Check pod events
kubectl describe pod <pod-name> -n game-2048

# Verify Fargate profile
eksctl get fargateprofile --cluster demo-cluster-2048
```

#### Issue: Cannot Access Game

**Solutions:**
- Wait 2-3 minutes for ALB to provision
- Check target health in AWS Console
- Verify security groups allow port 80

For more troubleshooting, see [docs/step-by-step-guide.md](docs/step-by-step-guide.md#troubleshooting).

## 📁 Project Structure
```
production-eks-deployment/
├── README.md                          # Project overview
├── LICENSE                            # MIT License
├── CONTRIBUTING.md                    # Contribution guidelines
├── .gitignore                         # Git ignore rules
├── docs/
│   ├── architecture-diagram.html      # Interactive architecture diagram
│   └── step-by-step-guide.md         # Detailed deployment guide
├── kubernetes/
│   ├── namespace.yaml                 # game-2048 namespace
│   ├── deployment.yaml                # 2048 game deployment
│   ├── service.yaml                   # NodePort service
│   └── ingress.yaml                   # ALB Ingress resource
├── iam/
│   └── iam-policy.json                # ALB Controller IAM policy
└── scripts/
    ├── 01-install-prerequisites.sh    # Install required tools
    ├── 02-create-eks-cluster.sh       # Create EKS cluster
    ├── 03-configure-iam-oidc.sh       # Setup IAM OIDC
    ├── 04-install-alb-controller.sh   # Install ALB controller
    ├── 05-deploy-game.sh              # Deploy 2048 game
    └── 99-cleanup.sh                  # Cleanup all resources
```

## 🎓 Learning Outcomes

After completing this project, you will understand:

### AWS Services
- EKS cluster architecture and management
- VPC networking (subnets, route tables, gateways)
- Application Load Balancer integration
- IAM roles and OIDC federation
- Fargate vs EC2 worker nodes

### Kubernetes Concepts
- Deployments and replica management
- Services (ClusterIP, NodePort)
- Ingress resources and controllers
- Namespaces for resource isolation
- Health probes (liveness, readiness)
- Resource requests and limits

### DevOps Practices
- Infrastructure as Code
- Automated deployment workflows
- Documentation-driven development
- Cost management and cleanup
- Troubleshooting methodologies

## 🧹 Cleanup

**IMPORTANT:** Delete all resources to avoid AWS charges
```bash
./scripts/99-cleanup.sh
```

This will remove:
- 2048 game deployment
- ALB and target groups
- ALB Controller
- EKS cluster
- VPC and networking resources
- IAM roles and policies

Verify cleanup in AWS Console.

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by the [AWS DevOps Zero to Hero](https://github.com/iam-veeramalla/aws-devops-zero-to-hero) course
- 2048 game by Gabriele Cirulli
- AWS Load Balancer Controller by AWS

## 📧 Contact

**Aditya Upasani**
- GitHub: [@adityaupasani2](https://github.com/adityaupasani2)

For questions or feedback, please open an issue in this repository.

---

⭐ **Star this repository if you found it helpful!**

**Happy Learning! 🚀**