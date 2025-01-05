# Infrastructure Setup

This section describes how to setup **UAT** environment for Application and Media hosting.
- It is meant for developers that have at least some experience with AWS and Terraform.
- If you don't want to use it, you can just delete the `infrastructure` and `bin/aws` folders.

## Application Hosting

Application hosting is provisioned by Terraform script that creates following resources in AWS:
- CloudFront
- ECS on EC2 (3x services - backend, frontend and database)
- VPC resources in your AWS account for application hosting

⚠ Approximate cost of this stack is between \$20 - \$30 per month (main cost is for the EC2 t3.small instance) and it is meant for hosting pre-production **UAT** environment (it is not suitable for production workloads).

### Prerequisites

- **Git CLI**
- [Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
    - **Option A/** Use Terraform Cloud to store the infrastructure state
        - Create [Terraform Account](https://app.terraform.io/public/signup/account)
        - Create [Terraform Organization](https://app.terraform.io/app/organizations)
            - Name of the organization must match the name specified in `backend.tf` - the name must be unique, so you will have to rename it
            - Workspace will be automatically created based on `backend.tf`
        - Set organization execution mode to local
    - **Option B/** Use local backend to store the infrastructure state
        - Setup [local backend](https://developer.hashicorp.com/terraform/language/backend/local)
- [AWS account](https://signin.aws.amazon.com/signup?request_type=register)
- [AWS CLI](https://www.youtube.com/watch?v=_DIRSI07kxY)
- Route 53 domain (will be used to create subdomains)
    - You can also use domain outside of AWS - by either changing the Terraform code or creating an alias for your domain in Route 53

### 1/ Clone the repository

```bash
git clone https://github.com/ironexdev/ent-stack.git <your project name>
```

### 2/ __Provide environment configuration__

Create and fill-in the `infrastructure/app-uat/.tfvars` file

```bash
frontend_domain_name = "uat.<my-site>.com"
backend_domain_name  = "uat.api.<my-site>.com"
route53_zone_id      = "<aws-route53-zone-id>"      
```

There is more variables that can be overridden, but they have default values.

Make sure to go through `variables.tf`, `providers.tf` and `backend.tf` files - especially if you want to use different region than **us-east-1**.

### 3/ __Initialize Terraform__

```bash
tf init
```

### 4/ __Create an execution plan__

```bash
tf plan -var-file=.tfvars
```

### 5/ __Execute and create AWS resources__

```bash
tf apply -var-file=.tfvars
```

Check deployment progress in AWS Console - [ECS](https://console.aws.amazon.com/ecs/v2/getStarted)

### Result

After the deployment is done, you will have VPC, CloudFront for TLS termination and three running placeholder ECS tasks, that will be updated/replaced during CI/CD deployment.

## Media Hosting

Media hosting is provisioned by Terraform script that creates an S3 bucket and a CloudFront distribution resources in AWS.

The solution supports two access methods: **Public** and **Signed URLs**. You can store and access media files based on your
access requirements, ensuring secure and efficient media delivery.

The Application (backend and frontend) does not use this by default - if you want to use it, then follow instructions in the **Result** section below.

Provisioned resources may incur costs:
- [CloudFront Pricing](https://aws.amazon.com/cloudfront/pricing/)
- [S3 Pricing](https://aws.amazon.com/s3/pricing/)
- The cost is same as if you would create these resources manually

__The solution does not handle media optimization.__

### Prerequisites

- **Git CLI**
- [Setup Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
    - A/ Use Terraform Cloud to store the infrastructure state
        - Create [Terraform Account](https://app.terraform.io/public/signup/account)
        - Create [Terraform Organization](https://app.terraform.io/app/organizations)
            - Name of the organization must match the name specified in `backend.tf` - the name must be unique, so you will have to rename it
                - <small>You can change backend.tf after you clone the repo to your local env (Setup section)</small>
            - Workspace will be automatically created based on `backend.tf`
        - Set organization execution mode to local
    - B/ Use local backend to store the infrastructure state
        - Setup [local backend](https://developer.hashicorp.com/terraform/language/backend/local)
- [Setup AWS CLI](https://www.youtube.com/watch?v=_DIRSI07kxY)
- [Create and upload SSH key to sign urls](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-trusted-signers.html#create-key-pair-and-key-group)
    - You will later need private_key.pem to sign urls in your app
- Add Key Group vars
    - Go to AWS CloudFront [key groups](https://console.aws.amazon.com/cloudfront/v4/home#/keygrouplist) and create a new key group
    - Copy id of the key group you created

### 1/ Clone the repository

```bash
git clone https://github.com/ironexdev/ent-stack.git <your project name>
```

### 2/ __Provide environment configuration__

Create and fill-in the `infrastructure/media-uat/.tfvars` file.

```bash
cloudfront_key_group_id = "<id>"    
```

- Refer to the prerequisites section for details on how to obtain it.

There is more variables that can be overridden, but they have default values.

Make sure to go through `variables.tf`, `providers.tf` and `backend.tf` files - especially if you want to use different region than **us-east-1**.

### 3/ __Initialize Terraform__

```bash
tf init
```

### 4/ __Create an execution plan__

```bash
tf plan -var-file=.tfvars
```

### 5/ __Execute and create AWS resources__

```bash
tf apply -var-file=.tfvars
```
### Result

After the deployment is done, you will have S3 bucket for storage and CloudFront for media hosting.

If you want to use Media hosting in the Application (backend and frontend), then you will have to add aws sdk for connection and create AWS IAM user (and credentials in frontend and backend) for the app with following permissions:

```bash
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
                "arn:aws:s3:::ent-media/*",
            ]
        }
    ]
}
```