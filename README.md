# ENT Stack DevOps

This repository provides comprehensive tooling and configuration for **CI/CD pipelines** and **infrastructure** deployment of the ENT Stack. By leveraging **AWS ECS**, **AWS S3**, and **CloudFront**, it enables straightforward hosting and automated application rollouts for a seamless UAT (User Acceptance Testing) experience.

---

## CI/CD Overview

The CI/CD pipeline automatically tests, builds, and deploys the ENT Stack—covering backend, frontend, and database components—into the UAT environment.

**Testing**  
- Each application layer (Express, Next.js, MySQL) undergoes automated testing within Docker containers using standardized images from **AWS ECR**. This ensures consistency and isolation for backend, frontend, and database tests.

**Deployment**  
- Once tests succeed, the pipeline pushes Docker images to ECR and deploys them via **AWS ECS**. This includes automatic ECS task updates for each service, ensuring that all components (backend, frontend, database) run the latest stable release.

**Secrets & Configurations**
- **AWS Systems Manager (SSM)** houses application secrets (prefixed with `APP_`).
- **GitHub Secrets** stores CI/CD-specific variables (e.g., `RELEASE_` and `ECS_`), ensuring sensitive data remains secure.

**Tooling**
- **GitHub Actions** automates workflows for testing, building, and deployment.
- **Docker** provides consistent build and runtime environments across all stages of the pipeline.

For more detailed steps and environment-specific guidelines:

- [CI/CD Setup](docs/cicd-setup.md)
- [CI/CD Documentation](docs/cicd-documentation.md)

---

## Infrastructure Overview

The infrastructure provisions an Express backend, a Next.js frontend, and a MySQL database for the UAT environment. Deployed on a single **t3.small** EC2 instance under **AWS ECS**, it integrates seamlessly with **CloudFront** for TLS termination and secured routing.

### Key Components

**EC2 Instance**
- Hosts all ECS tasks (backend, frontend, database) with auto-scaling potential based on ECS configurations.

**CloudFront**
- Handles TLS/HTTPS termination and acts as a secure entry point for both the frontend and backend services.

**AWS VPC**
- Incorporates subnets, route tables, and security groups. This isolation helps maintain a secure, network-segmented environment suitable for UAT-level testing.

### Optional Media Hosting
For projects needing secure or publicly accessible media assets, **AWS S3** and **CloudFront** can be integrated to deliver content at scale. The infrastructure can be extended with an additional S3 bucket and a dedicated CloudFront distribution for high-performance media delivery.

### Cost and Usage
This setup is optimized for UAT and pre-production workloads, with a typical monthly cost ranging from \$20 to \$40 depending on EC2 usage and data transfer volumes. It is not recommended for high-traffic production environments without further scaling or architectural modifications.

For in-depth infrastructure configuration and Terraform provisioning steps:

- [Infrastructure Setup](docs/infrastructure-setup.md)
- [Infrastructure Documentation](docs/infrastructure-documentation.md)
