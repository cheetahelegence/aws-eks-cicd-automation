# Terraform and Helm Integration

When a web service needs to reference resources created by Terraform, Terraform outputs can be used to expose those resource values and pass them into Helm through the CI/CD pipeline.

The general flow is:

```text
Terraform resource
→ Terraform output
→ GitHub Actions
→ Helm values / --set
→ Kubernetes manifest
```


## 1. Terraform Exposes the Resource Value

Terraform outputs are used to expose values from infrastructure resources.

For example, this project exposes the ECR repository URL:

```hcl
output "ecr_repository_url" {
  value = aws_ecr_repository.nginx.repository_url
}
```

## 2. CI/CD Reads the Terraform Output

GitHub Actions reads the Terraform output after the infrastructure is created:

```bash
ECR_REPOSITORY=$(terraform output -raw ecr_repository_url)
```

This allows the pipeline to retrieve the actual resource value dynamically instead of hard-coding it.


## 3. The Value Is Passed into Helm

The pipeline then passes the Terraform output into Helm:

```bash
helm upgrade --install web-demo ./helm/web-demo \
  --set image.repository="${ECR_REPOSITORY}" \
  --set image.tag="${IMAGE_TAG}"
```

In this project, this allows the Helm deployment to use the ECR repository created by Terraform.


## 4. The Same Pattern Can Be Used for Other Cloud Resources

The same approach can be used when a Helm chart needs to reference other Terraform-created resources.

For example, if Terraform creates a security policy:

```hcl
output "security_policy_name" {
  value = <terraform_resource>.name
}
```

The CI/CD pipeline can read the output:

```bash
SECURITY_POLICY=$(terraform output -raw security_policy_name)
```

Then pass it into Helm:

```bash
helm upgrade --install web-demo ./helm/web-demo \
  --set securityPolicy="${SECURITY_POLICY}"
```

The Helm template can reference the value:

```bash
metadata:
  annotations:
    security-policy: {{ .Values.securityPolicy }}
```


## Summary

The integration flow is:

```text
Terraform
→ expose resource information with outputs
→ CI/CD reads the outputs
→ values are passed into Helm
→ Helm injects them into Kubernetes manifests
```

This keeps infrastructure creation managed by Terraform while allowing the application deployment to dynamically reference the cloud resources it depends on.
