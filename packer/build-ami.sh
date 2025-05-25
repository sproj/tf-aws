#!/bin/bash
# Build script for Kubernetes AMI

set -e

# Configuration
KUBERNETES_VERSION="1.33"
REGION="eu-west-1"
AMI_NAME_PREFIX="tfaws-k8s-base"

echo "Building Kubernetes AMI..."
echo "Kubernetes Version: $KUBERNETES_VERSION"
echo "Region: $REGION"
echo "AMI Prefix: $AMI_NAME_PREFIX"

# Validate packer
if ! command -v packer &> /dev/null; then
    echo "ERROR: Packer is not installed"
    exit 1
fi

# Validate AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo "ERROR: AWS credentials not configured"
    exit 1
fi

# Initialize packer (download plugins)
echo "Initializing Packer..."
packer init k8s-base.pkr.hcl

echo "Variables file contents:"
cat ubuntu-22-k8s.pkrvars.hcl

# Validate packer configuration
echo "Validating Packer configuration..."
packer validate -var-file="ubuntu-22-k8s.pkrvars.hcl" k8s-base.pkr.hcl

# Build the AMI
echo "Building AMI... (this will take 5-10 minutes)"


packer build \
  -var-file="ubuntu-22-k8s.pkrvars.hcl" \
  -var "kubernetes_version=$KUBERNETES_VERSION" \
  -var "region=$REGION" \
  -var "ami_name_prefix=$AMI_NAME_PREFIX" \
  k8s-base.pkr.hcl

# Get the AMI ID from the output
echo ""
echo "Build complete! Check the output above for the AMI ID."
echo ""
echo "To use this AMI in your Terraform:"
echo "1. Copy the AMI ID from the output above"
echo "2. Update your terraform variables:"
echo "   ami_id = \"ami-xxxxxxxxxx\""
echo ""
echo "Or find it programmatically:"
echo "aws ec2 describe-images --owners self --filters \"Name=name,Values=$AMI_NAME_PREFIX-$KUBERNETES_VERSION-*\" --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' --output text"

echo ""
echo "Cleaning up old AMIs..."
./cleanup-old-amis.sh
echo ""