# EKS Terraform Task

This repository provisions an Amazon EKS environment with Terraform. It creates the following AWS resources:

- VPC with public, private, and database subnets.
- NAT gateway and subnet route tables.
- EC2 bastion host with an Elastic IP.
- SSH key pair for the bastion host and worker node access.
- IAM roles and policy attachments for EKS control plane and node groups.
- EKS cluster with a managed public node group.


## Prerequisites

Install and configure the following tools before running Terraform:

1. [Terraform](https://developer.hashicorp.com/terraform/install) `>= 1.6.0`.
2. AWS CLI configured with credentials that can create VPC, EC2, IAM, EKS, CloudWatch Logs, and related resources.
3. `kubectl` for connecting to the EKS cluster after deployment.
4. An AWS account with enough service quotas for VPCs, Elastic IPs, NAT gateways, EKS clusters, and EC2 instances.

Login to awscli using below command

```bash
export AWS_ACCESS_KEY_ID="put access key"
export AWS_SECRET_ACCESS_KEY="put secret key"
export AWS_DEFAULT_REGION="us-east-1"
```

Verify your AWS identity:

```bash
aws sts get-caller-identity
```

### Mention bucket name for remote backend in "1-s3-backend.tf" if bucker alread exist

## Configuration Files

The stack uses these variable files by default:

- `terraform.tfvars` - generic values such as AWS region, environment, and business division.
- `vpc.auto.tfvars` - VPC CIDR, subnet ranges, database subnet settings, and NAT gateway settings.
- `ec2bastion.auto.tfvars` - bastion host instance type and key pair name.
- `eks.auto.tfvars` - EKS cluster name, Kubernetes version, service CIDR, and endpoint access settings.

Review and update these files before applying the stack, especially:

## Execution Steps

Run all commands from the repository root.

### 1. Format Terraform Files

```bash
terraform fmt -recursive
```

### 2. Initialize Terraform

Downloads the required providers and modules.

```bash
terraform init
```

### 3. Validate the Configuration

Checks whether the Terraform configuration is syntactically valid.

```bash
terraform validate
```

### 4. Review the Execution Plan

Generates a deployment plan so you can review all resources before creation.

```bash
terraform plan
```

Optional: save the plan to a file.

```bash
terraform plan -out=tfplan
```

### 5. Apply the Configuration

Create the AWS resources.

```bash
terraform apply
```

Or apply a previously saved plan:

```bash
terraform apply tfplan
```

Type `yes` when Terraform asks for confirmation.

### 6. Review Terraform Outputs

After apply completes, inspect useful output values such as the EKS cluster endpoint, VPC ID, subnet IDs, and bastion host public IP.

```bash
terraform output
```

### 7. Configure kubectl Access

Update your local kubeconfig for the created EKS cluster. The cluster name is built from `business_divsion`, `environment`, and `cluster_name`.

With the default values in this repository, the cluster name is:

```text
hr-stag-eksdemo1
```

Run:

```bash
aws eks update-kubeconfig --region us-east-1 --name hr-stag-eksdemo1
```


### 8. Verify the Cluster

Check cluster and node access with `kubectl`:

```bash
kubectl cluster-info
kubectl get nodes
kubectl get pods -A
```

### 9. SSH to the Bastion Host

Get the bastion public IP from Terraform output:

```bash
terraform output ec2_bastion_public_ip
```

Then connect with the generated private key:

```bash
ssh -i private-key/eks-terraform-key.pem ec2-user@<bastion_public_ip>
```

## Destroy Steps


```bash
terraform destroy
```

Type `yes` when Terraform asks for confirmation.

If a saved plan file exists and is no longer needed, remove it:

```bash
rm -f tfplan
```

## Troubleshooting

### Terraform init fails

- Confirm you have internet access to download Terraform providers and modules.
- Confirm Terraform version is `>= 1.6.0`.

### AWS credential errors

- Run `aws sts get-caller-identity` to confirm credentials are available.
- Ensure your IAM user or role has permissions for EKS, EC2, IAM, VPC, CloudWatch Logs, and related resources.

### kubectl cannot connect

- Confirm `aws eks update-kubeconfig` used the correct AWS region and cluster name.
- Confirm the EKS cluster is active with:

```bash
aws eks describe-cluster --region us-east-1 --name hr-stag-eksdemo1 --query 'cluster.status'
```

### SSH connection fails

- Confirm the bastion host security group allows SSH from your current public IP.
- Confirm the private key exists and has secure permissions:

```bash
chmod 400 private-key/eks-terraform-key.pem
```
