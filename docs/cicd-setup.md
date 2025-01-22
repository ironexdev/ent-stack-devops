# CI/CD Setup

This section outlines the process for setting up CI/CD pipelines to facilitate testing, building, and deploying to the **UAT** environment.
- It depends on Infrastructure provisioned by this stack.

### Prerequisites

- **Git CLI**
- **GitHub** account
- <a href="https://github.com/jqlang/jq" target="_blank">**JQ**</a>

### 1/ Clone the DevOPS repository

```bash
git clone https://github.com/ironexdev/ent-stack-devops.git <your project name>
```

### 2/ Copy CI/CD from DevOPS repository to your Application repository

- Copy `.github` and `docker ` directories from the DevOPS repository to your Application repository
<small>
  - Prerequisite to this is having a previously created application repository based on the <a href="https://ent-stack.com" target="_blank">ENT Stack</a>
      - If you don't, then follow the <a href="https://ent-stack.com/ent-stack/setup/" target="_blank">setup guide</a>
  </small>

### 3/ Set application variables and secrets

- **Option A/** Go to AWS Systems Manager's [Parameter Store](https://console.aws.amazon.com/systems-manager/parameters)  and add `APP` parameters in following format:
    - Template: `/<project>/<environment><parameter name>`
    - Example: `/ent/uat/APP_BE_AWS_S3_ACCESS_KEY_ID`
        - <small>
            You can add String and SecureString parameters.
            SecureString parameters are encrypted using AWS Key Management Service (KMS) and can be decrypted only by specified roles.
          </small>

- **Option B/** Alternatively, use `bin/aws/ssm/ssm-put-parameters.sh` to add multiple parameters at once
    - You can rename `parameters.example.json` to `parameters.json` and `secrets.example.json` to `secrets.json` and fill in the values
    - Some values are prefilled, some are not, go through each of them and fill in/change the values
    - Example calls:
      - `FILE=parameters.json REGION=us-east-1 bin/aws/ssm/ssm-put-parameters.sh`
      - `FILE=secrets.json REGION=us-east-1 bin/aws/ssm/ssm-put-parameters.sh`
      - Call from the root directory of the project

💡 All variables and secrets in SSM are used by apps prefixed with `APP_`

### 4/ Set CI/CD variables and secrets

- Go to `https://github.com/<your account>/<your project name>/settings/environments`
- Click `New environment` and name it `uat`
- Add variables and secrets to the created environment
    - Some values are prefilled, some are not, go through each of them and fill in/change the values
    - Make sure values correspond with values defined in Terraform code

💡 All variables and secrets here are used by CICD prefixed with `ECS_` and `RELEASE_`

**Variables:**

```bash
ECS_BE_CPU=330
ECS_BE_MEMORY=330
ECS_BE_SERVICE=ent-uat-backend
ECS_BE_TASK_DEFINITION_FAMILY=ent-uat-backend
ECS_CLUSTER=ent-uat
ECS_DB_CPU=330
ECS_DB_MEMORY=512
ECS_DB_SERVICE=ent-uat-database
ECS_DB_TASK_DEFINITION_FAMILY=ent-uat-database
ECS_EXECUTION_ROLE_ARN=arn:aws:iam::<AWS account id>:role/ent-uat-ecs-task-execution-role
ECS_FE_CPU=330
ECS_FE_MEMORY=330
ECS_FE_SERVICE=ent-uat-frontend
ECS_FE_TASK_DEFINITION_FAMILY=ent-uat-frontend
ECS_TASK_ROLE_ARN=arn:aws:iam::<AWS account id>:role/ent-uat-ecs-task-role
RELEASE_AWS_REGION=us-east-1
RELEASE_AWS_ACCOUNT_ID=<AWS account id>
RELEASE_BE_IMAGE_REPOSITORY=ent-uat/node-express
RELEASE_BE_LOG_GROUP_NAME=/ecs/ent/uat/backend
RELEASE_BE_PORT=3001
RELEASE_DB_IMAGE_REPOSITORY=ent-uat/mysql
RELEASE_DB_LOG_GROUP_NAME=/ecs/ent/uat/database
RELEASE_DB_PORT=3306
RELEASE_FE_IMAGE_REPOSITORY=ent-uat/node-next
RELEASE_FE_LOG_GROUP_NAME=/ecs/ent/uat/frontend
RELEASE_FE_PORT=3000
RELEASE_MR_IMAGE_REPOSITORY=ent-uat/migrations
```

**Secrets:**

```bash
RELEASE_AWS_ACCESS_KEY_ID=<AWS admin user access key id>
RELEASE_AWS_SECRET_ACCESS_KEY=<AWS admin user secret access key>
```
- Access key id and secret access key can be created in AWS IAM
  - Create new user for your app
  - Go to user detail and click `Security credentials` tab
  - Create access key
- And then add this policy to the user:
  - Replace account-id with your AWS account
  - Change "ent-uat" to your ECS cluster name
```
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "AllowSSMParameterAccess",
			"Effect": "Allow",
			"Action": [
				"ssm:GetParameter",
				"ssm:GetParameters",
				"ssm:GetParametersByPath"
			],
			"Resource": "arn:aws:ssm:us-east-1:<account-id>:parameter/*"
		},
		{
			"Sid": "AllowECRAuthorizationToken",
			"Effect": "Allow",
			"Action": "ecr:GetAuthorizationToken",
			"Resource": "*"
		},
		{
			"Sid": "AllowECRRepositoryAccess",
			"Effect": "Allow",
			"Action": [
				"ecr:BatchGetImage",
				"ecr:GetDownloadUrlForLayer",
				"ecr:DescribeRepositories",
				"ecr:PutImage",
				"ecr:InitiateLayerUpload",
				"ecr:UploadLayerPart",
				"ecr:CompleteLayerUpload",
				"ecr:BatchCheckLayerAvailability"
			],
			"Resource": [
				"arn:aws:ecr:us-east-1:<account-id>:repository/ent-uat/*"
			]
		},
		{
			"Sid": "AllowTaskDefinitionManagement",
			"Effect": "Allow",
			"Action": [
				"ecs:RegisterTaskDefinition",
				"ecs:DescribeTaskDefinition"
			],
			"Resource": "arn:aws:ecs:us-east-1:<account-id>:task-definition/*"
		},
		{
			"Sid": "AllowServiceUpdate",
			"Effect": "Allow",
			"Action": [
				"ecs:UpdateService",
				"ecs:DescribeServices",
				"ecs:DescribeClusters",
				"ecs:ListTasks",
				"ecs:DescribeTasks"
			],
			"Resource": [
				"arn:aws:ecs:us-east-1:<account-id>:cluster/*",
				"arn:aws:ecs:us-east-1:<account-id>:service/*"
			]
		},
		{
			"Sid": "AllowPassRole",
			"Effect": "Allow",
			"Action": "iam:PassRole",
			"Resource": [
				"arn:aws:iam::<account-id>:role/ent-uat-ecs-task-role",
				"arn:aws:iam::<account-id>:role/ent-uat-ecs-task-execution-role"
			]
		}
	]
}
```

### 5/ How to run
- Go to `https://github.com/<your account>/<your project name>/actions`
- Select workflow
- Review inputs
- Click `Run workflow`

Deployment workflows use ECS task JSON definitions stored in `.github/ecs-task` to deploy services to ECS:
- JSON files are not valid as they contain placeholder values that are replaced during deployment
- You can use `bin/aws/ecs/delete-old-task-definitions.sh` helper to delete old task definitions from AWS ECS

Order of actions:

- (UAT) Database - build
- (UAT) Migrations - build
  - Make sure to run pnpm db:generate locally and commit the changes before running the workflow
- (UAT) Backend - build
- (UAT) Frontend - build
- Tests - run
- (UAT) Database - deploy
- (UAT) Migrations - deploy
  - MYSQL_HOST - `ECS > Clusters > Services > Select DB service > Tasks > Select Task` and use **Public IP**
- (UAT) Backend - deploy
    - MYSQL_HOST - go to `ECS > Clusters > Services > Select DB service > Tasks > Select Task` and use **Private IP**
- (UAT) Frontend - deploy


### 6/ Setup local pipeline with nektos/act for testing (optional)

- 6.1/ Install [nektos/act](https://github.com/nektos/act)
- 6.2/ Set app variables and secrets
    - Refer to step with the same name in **Setup** section
- 6.3/ Set CI/CD variables and secrets
    - Similar to GitHub Actions - you need to add CI/CD variables and secrets, but instead of using GitHub environment variables and secrets, you need to create:
        - `.github/workflows/.variables`
        - `.github/workflows/.secrets`

Some of the variables and secrets contain values wrapped in \<\> - these need to be filled in

Refer to list of variables and secrets in the **Setup** section.