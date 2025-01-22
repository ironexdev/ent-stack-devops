# CI/CD Documentation

This document outlines the workflows for testing, building, and deploying the application's backend, frontend, and database components to the UAT (User Acceptance Testing) environment. These workflows are implemented as steps in a GitHub Actions-based CI/CD pipeline.

### Configuration

- **Secrets and Variables:**
- `APP_` - prefixed secrets and variables are managed in **AWS Systems Manager (SSM)**.
- `RELEASE_` and `ECS_` - prefixed secrets and variables are maintained in **GitHub Secrets**.

### Testing

The CI/CD pipeline builds and tests the backend, frontend, and database components in isolated Docker containers using the latest image versions stored in **AWS Elastic Container Registry (ECR)**. Migrations are run within the pipeline to ensure database consistency. During this phase, the application leverages the `test` environment for both backend and frontend operations.

### Build, Deployment, and Migrations

**Build**
- All application components - backend, frontend, database, and migration images - are built using Docker.
- The resulting images are pushed to **AWS ECR**, ensuring consistent and secure image management.

**Deployment**
- Deployed using **AWS ECS (Elastic Container Service)**, where ECS tasks handle the deployment of the backend, frontend, and database services.
- This ensures seamless scalability and efficient orchestration.

**Database Migrations**
- Database migrations are executed via Docker directly in the CI/CD pipeline.
- You will have to specify DB host (in GitHub Action input variable) based on running DB ECS Task
  - Go to `ECS > Clusters > Services > Select DB service > Tasks > Select Task > Public IP`

### Docker

The stack contains 4 Docker images:

**Migrations**
- Used in CI/CD to run database migrations for `test` and `uat` environments.

**MySQL**
- Used in CI/CD to run database for `test` and `uat` environments.

**Express**
- Used in CI/CD to run backend for `test` and `uat` environments.
- Multistage production-grade image that can also be used in production.

**Next.js**
- Used in CI/CD to run frontend for `test` and `uat` environments.
- Multistage production-grade image that can also be used in production.