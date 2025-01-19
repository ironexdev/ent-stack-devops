# ENT Stack DevOps

This repository showcases one of many possible ways to build and deploy the <a href="https://ent-stack.com/" target="_blank">ENT Stack</a>.

It provides infrastructure provisioned on AWS using Terraform for conistetnt, version-controlled setups.

CI/CD pipelines are automated using GitHub Actions to handle testing, building, and deployment efficiently.

- [Infrastructure Setup](docs/infrastructure-setup.md)
- [Infrastructure Documentation](docs/infrastructure-documentation.md)
- [CI/CD Setup](docs/cicd-setup.md)
- [CI/CD Documentation](docs/cicd-documentation.md)

⚠️ **Disclaimers**:
- The hosting configuration is designed for non-production (UAT) workloads.
- To use this setup, you should have at least some experience with AWS and Terraform.

## Infrastructure Overview

The Terraform code defines a comprehensive AWS infrastructure, including a CloudFront distribution, ECS cluster, IAM roles, task definitions, VPC with public and private subnets, route tables, security groups, and CloudWatch log groups, providing a scalable and secure environment for the <a href="[https://github.com/ironexdev/ent-stack](https://ent-stack.com/)" target="_blank">ENT Stack</a>.

### Key Components

**ECS on EC2 Instance**
- The EC2 instance hosts all tasks (backend, frontend, database) based on ECS configurations.

**CloudFront**
- Handles TLS/HTTPS termination and acts as a secure entry point for both the frontend and backend services.

**AWS VPC**
- Incorporates subnets, route tables, and security groups. This isolation helps maintain a secure, network-segmented environment suitable for UAT-level testing.

### Optional Media Hosting
For projects needing secure or publicly accessible media assets, **AWS S3** and **CloudFront** can be integrated to deliver content at scale. The infrastructure can be extended with an additional S3 bucket and a dedicated CloudFront distribution for high-performance media delivery.

### Cost and Usage
This setup is optimized for UAT and pre-production workloads, with a typical monthly cost ranging from \$20 to \$30 depending on EC2 usage and data transfer volumes. It is not recommended for high-traffic production environments without further scaling or architectural modifications.

- [Infrastructure Setup](docs/infrastructure-setup.md)
- [Infrastructure Documentation](docs/infrastructure-documentation.md)

## CI/CD Overview

The CI/CD pipeline automatically tests, builds, and deploys the ENT Stack (covering backend, frontend, and database components) into the UAT environment.

**Testing**  
- Before deployment, the pipeline runs **tests** for the backend and frontend services, making sure that the codebase is stable and ready for release. 

**Deployment**  
- Once tests succeed, the pipeline pushes Docker images to ECR and deploys them via **AWS ECS**. This includes automatic ECS task updates for each service, making sure that all components (backend, frontend, database) run the latest stable release.

**Secrets & Configurations**
- **AWS Systems Manager (SSM)** contains application secrets (prefixed with `APP_`).
- **GitHub Secrets** stores CI/CD-specific variables (e.g., `RELEASE_` and `ECS_`), making sure sensitive data remain secure.

**Tooling**
- **GitHub Actions** automates workflows for testing, building, and deployment.
- **Docker** provides consistent build and runtime environments across all stages of the pipeline.

For more detailed steps and environment-specific guidelines:

- [CI/CD Setup](docs/cicd-setup.md)
- [CI/CD Documentation](docs/cicd-documentation.md)
