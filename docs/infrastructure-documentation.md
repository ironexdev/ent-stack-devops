# Infrastructure Documentation

This section describes **Application Hosting** and **Media Hosting** infrastructure, detailing the resources, configurations, and their intended purposes.

## Application Hosting

The **Application Hosting** infrastructure is designed to support a **UAT** (User Acceptance Testing) environment. It deploys scalable resources and provides secure and efficient hosting for application components.

### Infrastructure Resources

**CloudFront**
- Provides TLS termination for frontend and backend services.
- Configured with custom domain support (`aliases` linked to `var.domain_name`).
- Forwards requests to an origin server (`var.origin_domain`), which can be backend or frontend services.
- Enforces HTTPS for viewers via `viewer_protocol_policy` set to `redirect-to-https`.
- Uses a custom SSL certificate (`var.acm_certificate_arn`) for secure communication with clients.
- Integrated with Route 53 via an alias record, linking the distribution to the provided domain name.

**ECS on EC2**
- All services – frontend, backend, and database – are deployed with placeholder Node.js containers which are meant to be updated/replaced during CI/CD.

**VPC Resources**
- **Subnets**
    - Segregate public and private resources for secure networking.
- **Route Tables and Internet Gateways**
    - Facilitate communication within and outside the VPC.
- **Security Groups**
    - Restrict access based on defined protocols and IP ranges.

### Terraform Modules

**ECS Module**
- **Configuration**
    - Service names, task definitions, and scaling policies.
    - Auto-scaling based on resource utilization metrics.
- **Output**
    - ECS Cluster and Task Role ARNs for CI/CD integrations.

**CloudFront Module**
- **Configuration**
    - TLS termination setup for custom domains with SSL certificates.
- **Output**
    - Distribution IDs and endpoint URLs for integration.

**VPC Module**
- **Configuration**
    - CIDR block and subnet allocation.
    - Association of route tables with subnets.
- **Output**
    - VPC and subnet IDs for other dependent resources.

### Operational Costs

- The estimated monthly cost ranges from **\$30 to \$40**, main cost is for the EC2 instance.
- This environment is tailored for **UAT** and not recommended for production workloads.

## Media Hosting

The **Media Hosting** setup provides efficient and secure storage and distribution of media files, catering to diverse access requirements.

### Infrastructure Resources

**S3 Bucket**
- **Storage**
    - Handles file uploads, storage, and versioning.
- **Access Control**
    - Supports both public access and signed URLs for restricted access.

**CloudFront Distribution**
- Serves media files with low latency and high availability.
- Implements signed URLs for secure file access and usage tracking.

### Terraform Modules

**S3 Module**
- **Configuration**
    - Enables versioning to protect against accidental overwrites.
    - Defines lifecycle policies for cost management.
- **Output**
    - Bucket name and ARN for downstream applications.

**CloudFront Module**
- **Configuration**
    - Links to the S3 bucket as the origin.
    - Integrates with key groups for signed URL authentication.
- **Output**
    - CloudFront Distribution endpoints and access settings.

### Integration with Applications

**IAM Policies**
For seamless integration, create an AWS IAM user with the following policy to enable the application to access S3 resources:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::ent-media",
                "arn:aws:s3:::ent-media/*"
            ]
        }
    ]
}
```

### Operational Costs

- Costs are proportional to S3 storage usage and CloudFront data transfer.
- Designed for flexible scaling, ensuring predictable expenses.