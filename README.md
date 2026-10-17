# AWS EKS CI/CD Automation

## Overview

This project demonstrates a complete deployment workflow for a simple Nginx-based web service running on Kubernetes in AWS.
The infrastructure is provisioned with Terraform, the application image is built with Docker and stored in Amazon ECR, and the service is deployed to Amazon EKS using Helm.
GitHub Actions is used as the CI/CD pipeline to automate:
- Terraform initialization, validation, planning, and apply
- Docker image build
- Image push to Amazon ECR
- EKS kubeconfig configuration
- Helm deployment
- Deployment rollout verification
- External smoke testing

The application itself is intentionally simple. The main focus of this project is infrastructure provisioning, container deployment, and CI/CD automation.

The project also includes a multi-environment Helm structure for alpha, beta, staging, and production, together with documentation describing how GitOps could be integrated in the future.

## Architecture

```text
Developer
↓
GitHub Repository
↓
GitHub Actions
↓
AWS OIDC Authentication
↓
Terraform
├── VPC
├── Public / Private Subnets
├── NAT Gateway
├── Amazon EKS
└── Amazon ECR
↓
Docker Build
↓
Amazon ECR
↓
Helm
↓
Amazon EKS
↓
Kubernetes Deployment
↓
LoadBalancer Service
↓
/hello.txt
↓
Hello from Amazon EKS!
```

## Repository Structure

```text
aws-eks-cicd-automation/
├── .github/
│   └── workflows/
│       └── deploy.yml
├── docker/
│   ├── Dockerfile
│   ├── README.md
│   └── hello.txt
├── docs/
│   ├── gitops.md
│   └── terraform-helm-integration.md
├── helm/
│   └── web-demo/
│       ├── templates/
│       │   ├── deployment.yaml
│       │   └── service.yaml
│       ├── Chart.yaml
│       ├── values.yaml
│       ├── values-alpha.yaml
│       ├── values-beta.yaml
│       ├── values-staging.yaml
│       └── values-production.yaml
├── terraform/
│   ├── bootstrap/
│   ├── providers.tf
│   ├── versions.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── vpc.tf
│   ├── eks.tf
│   ├── ecr.tf
│   ├── github-oidc.tf
│   └── eks-access.tf
└── README.md
```

## Prerequisites

To deploy this project, the following are required:

- AWS account
- AWS CLI
- Terraform
- Docker
- kubectl
- Helm
- GitHub Actions
- AWS IAM / OIDC configuration
- Terraform remote state backend

## How to Run

Once the AWS and GitHub configuration is prepared, pushing changes to the configured branch triggers the GitHub Actions workflow.

The pipeline provisions the infrastructure, builds and pushes the Docker image, deploys the application with Helm, and runs a smoke test against the external LoadBalancer.

## Infrastructure

Terraform provisions the AWS infrastructure required by the application, including:

- VPC
- Public and private subnets across multiple Availability Zones
- Internet Gateway
- NAT Gateway
- Amazon EKS cluster
- EKS managed node group
- Amazon ECR repository
- GitHub Actions OIDC provider and IAM role
- EKS access entry for GitHub Actions

The worker nodes are placed in private subnets, while external traffic reaches the application through a Kubernetes `LoadBalancer` Service.

## Docker Image

The application uses an Nginx Alpine image.

```dockerfile
FROM nginx:alpine
COPY hello.txt /usr/share/nginx/html/hello.txt
EXPOSE 80
```

The endpoint `hello.txt` returns:

```text
Hello from Amazon EKS!
```

## Kubernetes and Helm

The application is deployed using a Helm chart.

The chart creates:

- Kubernetes Deployment
- Kubernetes LoadBalancer Service
- readiness probe
- liveness probe
- resource requests and limits

The Docker image repository and tag are dynamically provided by the CI/CD pipeline.

```bash
helm upgrade --install web-demo ./helm/web-demo \
  --set image.repository="${ECR_REPOSITORY}" \
  --set image.tag="${IMAGE_TAG}"
```

## CI/CD Pipeline

GitHub Actions automates the deployment flow:

```text
Checkout repository
↓
Authenticate to AWS using OIDC
↓
Terraform init / validate / plan / apply
↓
Read Terraform outputs
↓
Build Docker image
↓
Push image to Amazon ECR
↓
Configure EKS kubeconfig
↓
Deploy with Helm
↓
Wait for Kubernetes rollout
↓
Run external smoke test
```

## Multi-Environment Deployment and GitOps

The project uses one Helm chart with separate environment-specific values files:

```text
values-alpha.yaml
values-beta.yaml
values-staging.yaml
values-production.yaml
```

This allows the same application codebase and Helm templates to be reused while changing environment-specific settings such as replica count and resource allocation.

The current implementation uses GitHub Actions to deploy directly with Helm. The same structure can support a future GitOps workflow where GitHub Actions builds and publishes the image while a GitOps controller such as Argo CD manages deployment and reconciliation.

See `docs/gitops.md` for details.

## Terraform and Helm Integration

Terraform outputs are used to pass information about Terraform-created infrastructure into the application deployment.

For example, the ECR repository URL created by Terraform is read by GitHub Actions and passed into Helm as the image repository.

See `docs/terraform-helm-integration.md` for details.

## Verification

The infrastructure and application deployment can be verified with:

```bash
terraform plan
kubectl get nodes
kubectl get deployment,pods,svc
```

The external endpoint can be tested through the LoadBalancer:

```bash
curl http://<LOAD_BALANCER_HOSTNAME>/hello.txt
```

Expected response:

```text
Hello from Amazon EKS!
```

## Cleanup

To avoid ongoing AWS charges, resources should be removed after verification.

First remove the Helm release so Kubernetes can delete the AWS LoadBalancer:

```bash
helm uninstall web-demo
```

Verify that the Service and external LoadBalancer have been removed:

```bash
kubectl get svc
```

Then destroy the Terraform-managed infrastructure:

```bash
cd terraform
terraform destroy
```

If the ECR repository still contains Docker images, the images must be removed before the repository can be deleted.

The Terraform remote-state S3 bucket under `terraform/bootstrap` is managed separately and should be cleaned up last. Because versioning is enabled, existing state file versions and delete markers may need to be removed before the bucket can be destroyed.

## Notes

For simplicity, administrative AWS permissions were used for both the initial setup and the CI/CD role. In a production environment, Terraform and CI/CD should use dedicated IAM roles with least-privilege policies.

A single NAT Gateway is used to reduce infrastructure cost. In production, one NAT Gateway per Availability Zone would improve availability and avoid cross-AZ dependency.

For a production user-facing service, additional components such as HTTPS/TLS termination, Ingress, Web Application Firewall, autoscaling, centralized logging, and monitoring could be added. These are not implemented in this project to keep the scope focused on the core EKS, Helm, LoadBalancer, and CI/CD workflow.