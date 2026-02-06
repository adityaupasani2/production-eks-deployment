# Contributing to Production EKS Deployment

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## How to Contribute

### Reporting Issues

If you find a bug or have a suggestion:

1. Check if the issue already exists in the [Issues](../../issues) section
2. If not, create a new issue with:
   - Clear title and description
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior
   - Your environment details (OS, AWS region, tool versions)

### Submitting Changes

1. **Fork the Repository**
```bash
   # Click "Fork" button on GitHub
   git clone https://github.com/YOUR_USERNAME/production-eks-deployment.git
   cd production-eks-deployment
```

2. **Create a Branch**
```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/issue-description
```

3. **Make Your Changes**
   - Follow existing code style
   - Update documentation if needed
   - Test your changes thoroughly

4. **Commit Your Changes**
```bash
   git add .
   git commit -m "Brief description of changes
   
   - Detailed point 1
   - Detailed point 2"
```

5. **Push and Create Pull Request**
```bash
   git push origin feature/your-feature-name
```
   Then create a Pull Request on GitHub.

## Contribution Guidelines

### Code Style

- **Bash Scripts:**
  - Use `#!/bin/bash` shebang
  - Include `set -e` for error handling
  - Add comments for complex logic
  - Use descriptive variable names

- **YAML Files:**
  - Use 2 spaces for indentation
  - Include metadata labels
  - Add comments for non-obvious configurations

- **Documentation:**
  - Use clear, concise language
  - Include code examples
  - Update table of contents if adding sections

### Commit Messages

Follow this format:
```
Short summary (50 chars or less)

Detailed explanation if needed:
- Point 1
- Point 2
```

Good examples:
- ✅ `Add support for EC2 node groups`
- ✅ `Fix ALB controller installation timeout`
- ✅ `Update docs with troubleshooting section`

Bad examples:
- ❌ `fixed bug`
- ❌ `update`
- ❌ `WIP`

### Testing

Before submitting:

1. **Test Scripts:**
```bash
   shellcheck scripts/*.sh  # Install shellcheck first
```

2. **Test Deployment:**
   - Deploy to a test AWS account
   - Verify all steps work
   - Test cleanup process

3. **Verify Documentation:**
   - Ensure markdown renders correctly
   - Check all links work
   - Validate code examples

## Areas for Contribution

### 🐛 Bug Fixes
- Script errors
- Documentation typos
- Configuration issues

### ✨ New Features
- Support for EC2 worker nodes
- Multiple region deployment
- Custom domain with Route53
- HTTPS with ACM certificates
- Auto-scaling configurations
- Monitoring with Prometheus/Grafana

### 📚 Documentation
- Improved troubleshooting guides
- Video tutorials
- Cost optimization tips
- Security best practices

### 🧪 Testing
- Automated testing scripts
- Integration tests

## Questions?

Feel free to:
- Open an issue for discussion
- Ask questions in pull requests
- Reach out to maintainers

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers
- Focus on constructive feedback
- Help others learn

Thank you for contributing! 🎉