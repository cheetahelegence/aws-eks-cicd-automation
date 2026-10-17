# Multi-Environment Deployment with CI/CD and GitOps

CI/CD and GitOps can support multi-environment deployments by separating the application artifact from environment-specific deployment configuration.

CI/CD is responsible for building, testing, and publishing the application artifact, while GitOps keeps the desired configuration for each environment version-controlled in Git and synchronizes those changes to the target Kubernetes environment.

This allows the same application codebase, Docker image, and package configuration to be reused across alpha, beta, staging, and production, while only environment-specific settings change between deployments.


## Multi-Environment Structure in This Project

This project uses the same Helm chart for all environments, with separate Helm values files for environment-specific configuration:

```text
helm/web-demo/
├── Chart.yaml
├── values.yaml
├── values-alpha.yaml
├── values-beta.yaml
├── values-staging.yaml
├── values-production.yaml
└── templates/
```

The shared Helm templates contain the common Kubernetes configuration, while each environment-specific values file overrides only the settings that are different.

In this project, the main differences are replica count and resource requests/limits.

For example:

alpha
- minimal resources
- one replica
- used for early testing

beta
- slightly higher resources
- used for integration testing

staging
- multiple replicas
- configuration closer to production
- used for pre-production validation

production
- higher resource allocation
- multiple replicas
- used for production deployment

This structure allows all environments to reuse the same Helm chart and Kubernetes templates without duplicating manifests.


## CI/CD Support

The current GitHub Actions pipeline builds the application, pushes the Docker image to Amazon ECR, and deploys the application to EKS using Helm.

The same pipeline can support different environments by selecting the corresponding Helm values file.

For example, staging can be deployed with:

```bash
helm upgrade --install web-demo-staging ./helm/web-demo \
  -f ./helm/web-demo/values-staging.yaml \
  --set image.repository="${ECR_REPOSITORY}" \
  --set image.tag="${IMAGE_TAG}"
```

Production can use the same Helm chart with:

```bash
helm upgrade --install web-demo-production ./helm/web-demo \
  -f ./helm/web-demo/values-production.yaml \
  --set image.repository="${ECR_REPOSITORY}" \
  --set image.tag="${IMAGE_TAG}"
```

Therefore, the same codebase, Docker image, and Helm chart can be reused across environments, while the values file controls the environment-specific settings.


## GitOps Support

The same multi-environment structure can also support GitOps.

With GitOps, the desired deployment configuration for each environment is stored in Git.

For example, when a new application version should be promoted to staging, the staging deployment configuration can be updated through a commit or pull request.

A GitOps controller such as Argo CD can detect the change and synchronize the corresponding environment in EKS.

Example:

```text
Update staging configuration
→ Merge to Git
→ Argo CD detects the change
→ Argo CD synchronizes EKS
→ Staging environment is updated
```

The same image can then be promoted through:

```text
alpha
→ beta
→ staging
→ production
```

without rebuilding the image for every environment.


## Possible CI/CD and GitOps Integration

In the current implementation, GitHub Actions directly deploys the application to EKS using Helm.

A future improvement would be to combine the current CI/CD pipeline with GitOps:

```text
Developer
→ GitHub Actions
→ Build and test
→ Build Docker image
→ Push image to Amazon ECR
→ Update the target environment configuration in Git
→ Argo CD detects the change
→ Argo CD deploys and reconciles the corresponding environment in EKS
```

In this model, CI/CD handles building and validating the application artifact, while GitOps handles deployment and synchronization of environment-specific configuration.

Although GitOps is not implemented in this project, the current Helm-based multi-environment structure is designed to support this approach in the future.
