# AWS Pipelines Notes

# 1. Pipeline Introduction

## What is a Pipeline?

A pipeline is an automated sequence of steps that takes code from a version control repository (such as GitHub) and performs actions on it automatically:

```text
Code stored in GitHub
↓
Pipeline detects a change
↓
Pipeline runs automatically
↓
Tests
↓
Build
↓
Docker
↓
Deploy
```

Instead of manually:

```text
Write code
↓
Run tests
↓
Build application
↓
Build Docker image
↓
Push image
↓
Deploy application
```

A pipeline automates the entire process.

---

## Continuous Integration (CI)

Continuous Integration means automatically checking that new code changes work correctly whenever code is pushed to a repository (e.g. GitHub).

The goal is to catch problems early before the code is deployed.

Common CI activities include:

- installing dependencies
- running automated tests
- checking code quality (linting)
- building the application
- building Docker images

Example:

```text
Developer pushes code
↓
Pipeline starts
↓
Install dependencies
↓
Run tests
↓
Build application
↓
Build Docker image
↓
Build succeeds or fails
```

If any step fails:

```text
Pipeline fails
↓
Developer fixes issue
↓
Pushes code again
```

This helps ensure that only working code progresses through the pipeline.

---

## Continuous Deployment (CD)

Continuous Deployment means automatically releasing an application after it has successfully passed the Continuous Integration (CI) stage.

The goal is to reduce manual deployment work and ensure new changes reach users quickly and consistently.

Common CD activities include:

- deploying to ECS
- deploying to EC2
- deploying with Terraform
- deploying with CloudFormation

Example:

```text
Developer pushes code
↓
Pipeline starts
↓
Run tests
↓
Build application
↓
Build Docker image
↓
Deploy application
```

If the build succeeds:

```text
Application is deployed automatically
```

If the build fails:

```text
Deployment is skipped
↓
Developer fixes issue
↓
Pushes code again
```

This helps ensure that only successfully built and tested code is deployed.

---

## AWS Services Used

Several AWS services work together to create a CI/CD pipeline.

---

### CodePipeline

CodePipeline coordinates the overall pipeline.

Think of it as the:

```text
Pipeline Orchestrator
```

It defines the stages that should run and the order they should run in.

Example:

```text
Source
↓
Build
↓
Test
↓
Deploy
```

CodePipeline does not usually perform the work itself.

Instead, it triggers other AWS services such as:
- CodeBuild
- ECS
- CloudFormation

Example:

```text
GitHub
↓
CodePipeline
↓
CodeBuild
```

---

### CodeBuild

CodeBuild executes build commands.

Think of it as:

```text
The Worker
```

CodeBuild receives instructions and runs them inside a temporary build environment.

Examples:

```bash
npm install
npm test
docker build
docker push
```

CodeBuild typically reads these instructions from:

```text
buildspec.yml
```

Example:

```text
CodePipeline
↓
CodeBuild
↓
Runs buildspec.yml commands
```

---

### Secrets Manager

Secrets Manager securely stores sensitive information.

Examples:

- Docker passwords
- API keys
- database credentials
- access tokens

Instead of hardcoding credentials inside:

```text
GitHub
Dockerfiles
Terraform files
buildspec.yml
```

they can be stored securely in Secrets Manager.

Example:

```text
CodeBuild
↓
Requests Docker password
↓
Secrets Manager
↓
Returns password securely
```

This improves:
- security
- maintainability
- credential rotation

---

### IAM (Identity and Access Management)

IAM controls permissions within AWS.

Think of IAM as:

```text
AWS Authorisation
```

By default AWS services do not trust each other.

Permissions must be granted explicitly.

Examples:

```text
CodePipeline
↓
Can start CodeBuild
```

```text
CodeBuild
↓
Can read Secrets Manager
```

```text
CodeBuild
↓
Can push images to ECR
```

Without the correct IAM permissions, AWS services cannot communicate with each other.

Many pipeline errors are actually IAM permission issues.

---

### How These Services Work Together

```text
GitHub
↓
CodePipeline
↓
CodeBuild
↓
Secrets Manager
↓
DockerHub / ECR
↓
Deployment
```

Where:

- CodePipeline coordinates the process
- CodeBuild executes commands
- Secrets Manager provides credentials
- IAM controls permissions between services

---

## High Level Architecture

```text
GitHub
↓
CodePipeline
↓
CodeBuild
↓
DockerHub / ECR
↓
Deployment Target
```

---

# 2. Core Pipeline Workflow

## Goal

Build a Docker image automatically whenever code is pushed to GitHub.

---

# Step 1 - Create and Push GitHub Repository

The pipeline requires a GitHub repository to act as the source stage.

For this example, the repository should contain the following file structure:

```text
aws-codepipeline/
├── arsenal-team.sql
├── buildspec.yml
├── Dockerfile
└── README.md
```

CodePipeline will monitor this repository for changes and use it as the starting point of the pipeline.

---

# Step 2 - Create CodePipeline

Navigate to:

```text
AWS Console
↓
Developer Tools
↓
CodePipeline
↓
Create Pipeline
```

Example:

```text
aws-docker-build-and-push
```

---

## Choose Pipeline Type

Select:

```text
Build custom pipeline
```

---

## Choose Execution Mode

Example:

```text
Queued
```

Queued means:

```text
Pipeline 1
↓ completes
Pipeline 2
↓ completes
Pipeline 3
```

Only one execution runs at a time.

---

# Step 3 - Configure Source Stage

Choose source provider:

```text
GitHub (via GitHub App)
```

---

## Create GitHub Connection

AWS will ask you to:

- install GitHub App
- authorise GitHub
- choose repository
- choose branch

Example:

```text
Repository: goat-api
Branch: main
```

---

## What Happens Now?

Every push to:

```text
main
```

can automatically trigger the pipeline.

---

# Step 4 - Create CodeBuild Project

Create a build project.

Example:

```text
code-build-aws-docker
```

Recommended settings:

```text
Environment:
Ubuntu

Compute:
Small

Buildspec:
Use buildspec.yml
```

---

# Step 5 - Create Basic buildspec.yml

Start with a simple test.

```yaml
version: 0.2

phases:
  build:
    commands:
      - echo "Hello from CodeBuild"
```

---

## Why Start Simple?

This confirms:

```text
GitHub
↓
CodePipeline
↓
CodeBuild
```

is working before introducing Docker.

---

# Step 6 - Run Pipeline

Run:

```text
Release Change
```

or push code to GitHub.

Confirm:

- pipeline succeeds
- build succeeds
- logs appear in CodeBuild

---

# Step 7 - Create Docker Credentials Secret

Navigate to:

```text
AWS Secrets Manager
↓
Store New Secret
```

Choose:

```text
Other Type of Secret
```

---

## Create Secret Values

Example:

```text
SECRET_USERNAME = myDockerUser
SECRET_PASSWORD = myDockerPassword
```

Example secret name:

```text
pipeline-docker-auth
```

---

# Step 8 - Give CodeBuild Access To Secret

Find:

```text
CodeBuild
↓
Project
↓
Service Role
```

Add permission:

```json
{
  "Effect": "Allow",
  "Action": [
    "secretsmanager:GetSecretValue"
  ],
  "Resource": [
    "secret ARN"
  ]
}
```

---

# Step 9 - Login To DockerHub

Update buildspec:

```yaml
version: 0.2

env:
  secrets-manager:
    SECRET_USERNAME: pipeline-docker-auth:SECRET_USERNAME
    SECRET_PASSWORD: pipeline-docker-auth:SECRET_PASSWORD

phases:
  pre_build:
    commands:
      - echo "$SECRET_PASSWORD" | docker login -u "$SECRET_USERNAME" --password-stdin
```

---

# Step 10 - Build Docker Image

Add:

```yaml
build:
  commands:
    - docker build -t my-docker-image .
```

This creates:

```text
Dockerfile
↓
Docker Image
```

---

# Step 11 - Push Docker Image

Add:

```yaml
post_build:
  commands:
    - docker tag my-docker-image "$SECRET_USERNAME/my-docker-image:latest"
    - docker push "$SECRET_USERNAME/my-docker-image:latest"
```

---

# Step 12 - Run Pipeline Again

Pipeline now performs:

```text
GitHub
↓
CodePipeline
↓
CodeBuild
↓
Docker Login
↓
Docker Build
↓
Docker Push
```

Confirm image appears in:

```text
DockerHub
```

---

# 3. buildspec.yml Reference

## What is buildspec.yml?

A `buildspec.yml` file tells CodeBuild exactly what commands to run.

Think of it as:

```text
Build Instructions
```

for AWS CodeBuild.

---

## Basic Structure

```yaml
version: 0.2

phases:
  install:
    commands:

  pre_build:
    commands:

  build:
    commands:

  post_build:
    commands:

artifacts:
  files:
    - '**/*'

env:
  variables:
    MY_VAR: "value"
```

---

## version

Required.

Example:

```yaml
version: 0.2
```

Specifies buildspec format version.

---

## install

Optional.

Runs first.

Common uses:

- npm install
- install tools
- setup environment

Example:

```yaml
install:
  commands:
    - npm install
```

---

## pre_build

Optional.

Runs before build.

Common uses:

- Docker login
- ECR login
- linting
- environment setup

Example:

```yaml
pre_build:
  commands:
    - echo "Preparing build"
```

---

## build

Main build phase.

Usually required.

Common uses:

- tests
- application build
- Docker build

Example:

```yaml
build:
  commands:
    - docker build -t my-image .
```

---

## post_build

Runs after build completes.

Common uses:

- Docker push
- deployment preparation
- notifications

Example:

```yaml
post_build:
  commands:
    - docker push my-image
```

---

## artifacts

Defines files to preserve after build.

Example:

```yaml
artifacts:
  files:
    - '**/*'
```

Useful for:

- deployment packages
- reports
- compiled applications

---

## env

Defines environment variables.

Example:

```yaml
env:
  variables:
    NODE_ENV: production
```

For secrets use:

```yaml
env:
  secrets-manager:
```

instead.

---

# 4. IAM & Permissions

## Why Permissions Matter

AWS services do NOT automatically trust each other.

Example:

```text
CodePipeline
↓
CodeBuild
```

CodePipeline must be granted permission to start CodeBuild.

---

## CodePipeline → CodeBuild

Required permissions:

```json
codebuild:StartBuild
codebuild:BatchGetBuilds
```

Purpose:

```text
Start builds
Check build status
```

---

## CodeBuild → Secrets Manager

Required permission:

```json
secretsmanager:GetSecretValue
```

Purpose:

```text
Read Docker credentials
```

---

## Common Error

Example:

```text
User is not authorized to perform:
codebuild:StartBuild
```

Meaning:

```text
CodePipeline lacks permission to start CodeBuild
```

---

# 5. AWS Secrets Manager

## What is Secrets Manager?

Secrets Manager securely stores sensitive information.

Examples:

- Docker passwords
- API keys
- database credentials
- tokens

---

## Why Not Hardcode Secrets?

Avoid storing secrets in:

```text
GitHub
Dockerfile
buildspec.yml
Terraform files
```

because:

- source control is visible
- credentials can leak
- passwords become difficult to rotate

---

## Accessing Secrets

Store:

```text
SECRET_USERNAME
SECRET_PASSWORD
```

in Secrets Manager.

Reference them in buildspec:

```yaml
env:
  secrets-manager:
    SECRET_USERNAME: pipeline-docker-auth:SECRET_USERNAME
    SECRET_PASSWORD: pipeline-docker-auth:SECRET_PASSWORD
```

---

# 6. Deployment Options

After the image is built and pushed, it can be deployed.

---

## DockerHub

Stores Docker images.

---

## Amazon ECR

AWS-managed Docker registry.

Alternative to DockerHub.

---

## EC2

Run containers manually on EC2 servers.

Good for learning.

---

## ECS Fargate

AWS managed container hosting.

Good for production.

---

## CloudFormation

AWS Infrastructure as Code.

---

## Terraform

Infrastructure as Code.

Can provision:

- EC2
- ECS
- databases
- networking
- load balancers

---

# 7. Putting Everything Together

```text
Developer pushes code
↓
GitHub
↓
CodePipeline triggered
↓
CodeBuild starts
↓
Secrets retrieved
↓
Docker login
↓
Docker build
↓
Docker push
↓
Deploy
```

---

# Example End Goal

```text
Developer pushes code
↓
GitHub
↓
CodePipeline
↓
CodeBuild
↓
Docker image built
↓
Docker image pushed
↓
Terraform-managed infrastructure updated
↓
Application deployed
```

---

# Skills To Practise

Good follow-on projects:

- Dockerise an API
- Dockerise API + database
- Build CodePipeline
- Build CodeBuild project
- Use Secrets Manager
- Push Docker images automatically
- Deploy to EC2
- Deploy to ECS
- Add automated testing stage
- Integrate Terraform deployments














