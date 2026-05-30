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

Create a new AWS CodePipeline that will orchestrate the CI/CD workflow:

```text
GitHub
↓
CodePipeline
↓
CodeBuild
↓
Docker Build
↓
Docker Registry (DockerHub / ECR)
↓
Deployment
```

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

Example pipeline name:

```text
aws-docker-build-and-push
```

---

## Choose Pipeline Type

Select:

```text
Build custom pipeline
```

This allows you to configure the source, build and deployment stages manually.

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

Only one pipeline execution runs at a time.

---

# Step 3 - Configure Source Stage

The source stage defines where CodePipeline will retrieve the application code from.

For this project, the source provider is:

```text
GitHub (via GitHub App)
```

---

## Create GitHub Connection

In the connection section select:

```text
Connect to GitHub
```

Then:

```text
Create New Connection
```

Example connection name:

```text
aws-github-service-connection
```

Click:

```text
Connect to GitHub
```

---

## Install GitHub App

AWS will redirect you to GitHub.

Select:

```text
Install a New App
```

Then:

* select your GitHub account
* choose **Only Select Repositories**
* select the repository:

```text
aws-codepipeline
```

Complete the installation.

---

## Complete Connection

After GitHub redirects back to AWS:

```text
Click Connect
```

This establishes the connection between:

```text
AWS CodePipeline
↓
GitHub Account
```

allowing AWS to access the selected repository.

---

## Select Repository

Choose:

```text
Repository Name: vikkapoor25/aws-codepipeline
Default Branch: main
```

This tells CodePipeline:

* which GitHub repository to monitor
* which branch should trigger pipeline executions

---

## How it Works

Every push to:

```text
main
```

can automatically trigger the pipeline.

Example:

```text
Developer pushes code
↓
GitHub repository updated
↓
CodePipeline detects change
↓
Pipeline starts automatically
```

This repository now acts as the source stage for the remainder of the pipeline.

---

# Step 4 - Complete Initial Pipeline Setup

We will configure the actual build process later using a `buildspec.yml` file.

For now, we want to skip the build, test and deploy stages. However, CodePipeline requires at least one stage to contain an action.

To satisfy this requirement, add:

```bash
echo "aws-codepipeline"
```

to the build stage.

This allows the pipeline to execute successfully while we focus on configuring the GitHub source connection. The placeholder build action will be replaced later when we configure AWS CodeBuild.

---

# Step 5a - Verify Source Stage Permissions

After creating the pipeline, verify that the source stage completes successfully.

## Common Error: GitHub Connection Permissions

Error:

```text
Unable to use Connection...
The provided role does not have sufficient permissions.
```

This means the CodePipeline service role does not have permission to use the GitHub connection created in the source stage.

---

## Fix

Navigate to:

```text
IAM
↓
Roles
↓
AWSCodePipelineServiceRole-<region>-<pipeline-name>
↓
Add Permissions
↓
Create Inline Policy
↓
JSON
```

Add the following policy:

```json
{
  "Effect": "Allow",
  "Action": [
    "codeconnections:UseConnection"
  ],
  "Resource": "GitHub Connection ARN"
}
```

Give the policy a meaningful name, for example:

```text
aws-codepipeline-use-github-connection
```

Then create the policy.

This policy grants CodePipeline permission to use the GitHub connection configured in the source stage.

**NOTE:** The GitHub Connection ARN can be found:

* in AWS CodeConnections, or
* directly in the source stage error message.

Example:

```text
arn:aws:codeconnections:<region>:<account-id>:connection/<connection-id>
```

---

## Retry Pipeline

After creating the inline policy:

```text
CodePipeline
↓
Release Change
```

or:

```text
Retry Stage
```

The source stage should now complete successfully and allow the pipeline to continue.

---

# Step 5b - Verify Build Stage Permissions

After creating the pipeline, verify that the build stage completes successfully.

## Common Error: CloudWatch Logging Permissions

Error:

```text
Action failed with status: FAILED.

Service role does not have permissions to create Amazon CloudWatch log streams.

Add:
logs:CreateLogGroup
logs:CreateLogStream
logs:PutLogEvents
```

This means the CodePipeline service role does not have permission to create and write CloudWatch logs.

---

## Fix

Navigate to:

```text
IAM
↓
Roles
↓
AWSCodePipelineServiceRole-<region>-<pipeline-name>
↓
Add Permissions
↓
Create Inline Policy
↓
JSON
```

Add the following policy:

```json
{
  "Effect": "Allow",
  "Action": [
    "logs:CreateLogGroup",
    "logs:CreateLogStream",
    "logs:PutLogEvents"
  ],
  "Resource": "*"
}
```

Give the policy a meaningful name, for example:

```text
aws-codepipeline-cloudwatch-logs
```

Then create the policy.

This policy grants CodePipeline permission to create log groups, create log streams and write log events to CloudWatch.

**NOTE:** CodePipeline writes execution logs to CloudWatch.

The default log group is typically:

```text
/aws/codepipeline/<pipeline-name>
```

Without these permissions, the pipeline cannot write execution logs and the build stage may fail.

---

## Retry Pipeline

After creating the inline policy:

```text
CodePipeline
↓
Release Change
```

or:

```text
Retry Stage
```

The build stage should now complete successfully and allow the pipeline to continue.

---

# Step 6 - Configure Build Action

The build stage defines what should happen after code is retrieved from GitHub.

For this project, we will use:

```text
AWS CodeBuild
```

to execute the commands defined in `buildspec.yml`.

---

## Edit Build Stage

Navigate to:

```text
CodePipeline
↓
Edit Pipeline
↓
Edit Build Stage
↓
Edit Action
```

Configure the action:

```text
Action Name:
Docker-Build-and-Push

Action Provider:
AWS CodeBuild
```

Selecting:

```text
AWS CodeBuild
```

tells CodePipeline that the build stage should be executed by a CodeBuild project.

---

## Select or Create CodeBuild Project

After selecting:

```text
AWS CodeBuild
```

AWS will prompt you to select an existing CodeBuild project or create a new one.

For this project, select:

```text
Create Project
```

and complete Step 7 before continuing with Step 6.

---

## Configure Output Artifact

Specify:

```text
BuildArtifact
```

as the output artifact.

This allows build output to be passed to later pipeline stages if required.

---

## Save Changes

```text
Done
↓
Save Action
```

The build stage is now configured to use AWS CodeBuild.

---

# Step 7 - Create CodeBuild Project

When configuring the build action in Step 6, select:

```text
Create Project
```

This creates the CodeBuild project that will execute the commands defined in `buildspec.yml`.

---

## Configure Project

Example project name:

```text
code-build-aws-docker
```

Recommended settings:

```text
Operating System:
Ubuntu
```

Specify:

```text
Buildspec:
Use buildspec file
```

and enter:

```text
buildspec.yml
```

to match the file stored in the GitHub repository.

**NOTE:** You can create the CodeBuild project separately before editing the pipeline, but you will need to configure the source repository manually. Creating the project from within the build action is usually simpler.

---

## Save Project

```text
Save Project
↓
Return to Build Action
↓
Save Pipeline
```

The build stage is now linked to the CodeBuild project.

---

## What Happens Now?

When the pipeline reaches the build stage:

```text
GitHub Push
↓
CodePipeline Starts
↓
Build Stage Starts
↓
CodeBuild Starts
↓
Reads buildspec.yml
↓
Executes Commands
```

---

# Step 8 - Verify CodeBuild Integration Permissions

After creating the CodeBuild project and linking it to the build action, verify that CodePipeline can successfully start the build.

## Common Error: CodeBuild Start Permissions

Error:

```text
is not authorized to perform:
codebuild:StartBuild
```

Example:

```text
Error calling startBuild:

User:
AWSCodePipelineServiceRole-<region>-<pipeline-name>

is not authorized to perform:

codebuild:StartBuild

on resource:

arn:aws:codebuild:<region>:<account-id>:project/<project-name>
```

This means the CodePipeline service role does not have permission to start the CodeBuild project.

---

## Fix

Navigate to:

```text
IAM
↓
Roles
↓
AWSCodePipelineServiceRole-<region>-<pipeline-name>
↓
Add Permissions
↓
Create Inline Policy
↓
JSON
```

Add the following policy:

```json
{
  "Effect": "Allow",
  "Action": [
    "codebuild:StartBuild",
    "codebuild:BatchGetBuilds"
  ],
  "Resource": "CodeBuild Project ARN"
}
```

Give the policy a meaningful name, for example:

```text
aws-codepipeline-start-codebuild
```

Then create the policy.

This policy grants CodePipeline permission to start the CodeBuild project and retrieve build status information.

**NOTE:** The CodeBuild Project ARN can be found in:

```text
CodeBuild
↓
Build Projects
↓
<Project Name>
```

---

## Retry Pipeline

After creating the inline policy:

```text
CodePipeline
↓
Release Change
```

or:

```text
Retry Stage
```

The build stage should now be able to start the CodeBuild project successfully.

---

# Step 9 - Create Basic buildspec.yml

We will create a simple `buildspec.yml` to verify that:

```text
GitHub
↓
CodePipeline
↓
CodeBuild
```

is working correctly before introducing Docker.

**NOTE:** If `buildspec.yml` is empty, CodeBuild will fail because it requires valid YAML instructions to execute.

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

# Step 10 - Run Pipeline

Run:

```text
Release Change
```

or push code to GitHub.

Confirm:

* pipeline succeeds
* build succeeds
* logs appear in CodeBuild

---

# Step 11 - Create Docker Credentials Secret

CodeBuild will need DockerHub credentials in order to authenticate and push Docker images.

Rather than hardcoding credentials into:

```text
buildspec.yml
```

we will store them securely in AWS Secrets Manager.

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

Secrets Manager stores data as key/value pairs.

For this example, create the following key/value pairs:

```text
username = <your DockerHub username>
password = <your DockerHub password>
```

Here:

```text
Key: username
Value: DockerHub username

Key: password
Value: DockerHub password
```

Example secret name:

```text
pipeline-docker-auth
```

---

## Why Are We Doing This?

Later, CodeBuild will retrieve these values from Secrets Manager and expose them as environment variables.

Example:

```yaml
env:
  secrets-manager:
    SECRET_USERNAME: "pipeline/docker/auth:username"
    SECRET_PASSWORD: "pipeline/docker/auth:password"
```

This allows CodeBuild to authenticate with DockerHub without storing sensitive credentials directly in source control.

```text
Secrets Manager
↓
CodeBuild
↓
Docker Login
↓
Docker Push
```

---

# Step 12 - Give CodeBuild Access To Secret

After creating the Docker credentials secret, CodeBuild must be granted permission to retrieve it.

## Why Is This Required?

CodeBuild will later attempt to retrieve:

```text
username
password
```

from:

```text
pipeline-docker-auth
```

Without permission, the build will fail when attempting to access Secrets Manager.

---

## Grant Permission

Navigate to:

```text
CodeBuild
↓
Project
↓
Service Role
↓
Add Permissions
↓
Create Inline Policy
↓
JSON
```

Add the following policy:

```json
{
  "Effect": "Allow",
  "Action": [
    "secretsmanager:GetSecretValue"
  ],
  "Resource": "Secret ARN"
}
```

Give the policy a meaningful name, for example:

```text
aws-codebuild-read-docker-secret
```

Then create the policy.

This policy grants CodeBuild permission to retrieve the DockerHub credentials stored in Secrets Manager.

**NOTE:** The Secret ARN can be found in:

```text
Secrets Manager
↓
pipeline-docker-auth
↓
Secret ARN
```

---

# Step 14 - Build Docker Image

Extend the `buildspec.yml` by adding a build phase:

```yaml
build:
  commands:
    - echo "Building Docker image..."
    - docker build -t vikkapoor25/arsenal-db:latest .
```

This creates:

```text
Dockerfile
↓
Docker Image
```

The image is tagged:

```text
vikkapoor25/arsenal-db:latest
```

---

# Step 15 - Push Docker Image

Extend the `buildspec.yml` by adding a post-build phase:

```yaml
post_build:
  commands:
    - echo "Pushing Docker Image..."
    - docker push vikkapoor25/arsenal-db:latest
```

This pushes the Docker image to DockerHub.

```text
Docker Image
↓
DockerHub
```

---

# Step 16 - Run Pipeline Again

Commit and push the updated `buildspec.yml`.

Then either:

```text
CodePipeline
↓
Release Change
```

or:

```text
Git Push
↓
Pipeline Triggered Automatically
```

The pipeline now performs:

```text
GitHub
↓
CodePipeline
↓
CodeBuild
↓
Retrieve Secret
↓
Docker Login
↓
Docker Build
↓
Docker Push
```

Confirm the image appears in:

```text
DockerHub
↓
Repositories
↓
vikkapoor25/arsenal-db
```

---

# 3. buildspec.yml Cheat Sheet

## What is buildspec.yml?

A `buildspec.yml` file tells AWS CodeBuild exactly what commands to execute.

Think of it as:

```text
Build Instructions
```

for CodeBuild.

When CodePipeline starts CodeBuild:

```text
CodePipeline
↓
CodeBuild
↓
Reads buildspec.yml
↓
Executes commands
```

---

## Basic Structure

```yaml
version: 0.2

env:

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
```

---

## version

Required.

Example:

```yaml
version: 0.2
```

Specifies the buildspec file format version.

---

## env

Used to define environment variables and retrieve secrets.

Example:

```yaml
env:
  variables:
    APP_ENV: production
```

Secrets Manager example:

```yaml
env:
  secrets-manager:
    SECRET_USERNAME: "pipeline-docker-auth:username"
    SECRET_PASSWORD: "pipeline-docker-auth:password"
```

---

## install

Runs first.

Common uses:

* install dependencies
* install tools
* configure environment

Example:

```yaml
install:
  commands:
    - npm install
```

---

## pre_build

Runs before the main build.

Common uses:

* Docker login
* ECR login
* linting
* setup tasks

Example:

```yaml
pre_build:
  commands:
    - echo "Preparing build"
```

---

## build

Main build phase.

Common uses:

* run tests
* build applications
* build Docker images

Example:

```yaml
build:
  commands:
    - docker build -t my-image .
```

---

## post_build

Runs after the build completes.

Common uses:

* Docker push
* deployment preparation
* notifications

Example:

```yaml
post_build:
  commands:
    - docker push my-image
```

---

## artifacts

Defines files to preserve after the build.

Example:

```yaml
artifacts:
  files:
    - Dockerfile
```

Useful for:

* deployment packages
* reports
* compiled applications

---

## Final Example

```yaml
version: 0.2

env:
  secrets-manager:
    SECRET_USERNAME: "pipeline-docker-auth:username"
    SECRET_PASSWORD: "pipeline-docker-auth:password"

phases:
  pre_build:
    commands:
      - echo "$SECRET_PASSWORD" | docker login -u "$SECRET_USERNAME" --password-stdin

  build:
    commands:
      - docker build -t vikkapoor25/arsenal-db:latest .

  post_build:
    commands:
      - docker push vikkapoor25/arsenal-db:latest

artifacts:
  files:
    - Dockerfile
```

---

# 4. Troubleshooting Guide

## GitHub Connection Permissions

### Error

```text
Unable to use Connection...
The provided role does not have sufficient permissions.
```

### Meaning

CodePipeline cannot use the GitHub connection.

### Fix

Grant:

```json
codeconnections:UseConnection
```

to the CodePipeline service role.

---

## CloudWatch Logging Permissions

### Error

```text
Service role does not have permissions to create Amazon CloudWatch log streams.
```

### Meaning

CodePipeline cannot create or write CloudWatch logs.

### Fix

Grant:

```json
logs:CreateLogGroup
logs:CreateLogStream
logs:PutLogEvents
```

to the CodePipeline service role.

---

## CodeBuild Start Permissions

### Error

```text
is not authorized to perform:
codebuild:StartBuild
```

### Meaning

CodePipeline cannot start the CodeBuild project.

### Fix

Grant:

```json
codebuild:StartBuild
codebuild:BatchGetBuilds
```

to the CodePipeline service role.

---

## Empty buildspec.yml

### Error

```text
YAML_FILE_ERROR
```

or

```text
wrong number of container tags, expected 1
```

### Meaning

The `buildspec.yml` file is empty or contains invalid YAML.

### Fix

Ensure `buildspec.yml` contains valid YAML instructions.

Example:

```yaml
version: 0.2

phases:
  build:
    commands:
      - echo "Hello from CodeBuild"
```

---

## Secrets Manager Permissions

### Error

```text
AccessDeniedException
```

when retrieving secrets.

### Meaning

CodeBuild cannot read values from Secrets Manager.

### Fix

Grant:

```json
secretsmanager:GetSecretValue
```

to the CodeBuild service role.

---

## Docker Login Failed

### Error

```text
unauthorized: incorrect username or password
```

### Meaning

DockerHub rejected the supplied credentials.

### Fix

Verify:

```text
Secret Name:
pipeline-docker-auth

Keys:
username
password
```

Confirm:

```text
username = DockerHub username
password = DockerHub password or access token
```

---

## Duplicate Policy Names

### Error

```text
A policy called ... already exists.
Duplicate names are not allowed.
```

### Meaning

A previous lab or pipeline left behind IAM resources.

### Fix

Navigate to:

```text
IAM
↓
Policies
```

Check whether the policy is attached to any roles.

If not attached:

```text
Delete Policy
```

and recreate the resource.

---

## Useful Troubleshooting Process

When a pipeline fails:

```text
CodePipeline
↓
Failed Stage
↓
View Details
↓
Open CloudWatch Logs
↓
Read Error Message
↓
Identify Missing Permission / Configuration
↓
Fix
↓
Retry Stage
```

---

# 5. Next Steps

This pipeline currently performs:

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

---

## Deploy and Run Containers

The current pipeline builds and stores a Docker image but does not run a container.

Current workflow:

```text
GitHub
↓
CodePipeline
↓
CodeBuild
↓
Docker Push
↓
DockerHub
```

To run the application, a deployment stage must be added.

Example:

```text
GitHub
↓
CodePipeline
↓
CodeBuild
↓
Docker Push
↓
EC2 / ECS
↓
docker run
↓
Container Running
```

A Docker image is simply a template.

The application only runs when a container is created from that image.

---

## Push to Amazon ECR

Replace DockerHub with:

```text
Amazon Elastic Container Registry (ECR)
```

AWS-native Docker image storage.

---

## Deploy to EC2

Automatically pull the latest image and start containers on EC2.

---

## Deploy to ECS

Deploy containers using:

```text
Amazon ECS Fargate
```

for a fully managed container platform.

---

## Add Automated Testing

Before building Docker images:

```text
Install Dependencies
↓
Run Tests
↓
Build Docker Image
```

---

## Deploy with Terraform

Provision infrastructure automatically:

```text
Terraform
↓
VPC
↓
EC2 / ECS
↓
Databases
↓
Networking
```

---

## Skills To Practise

* Dockerise a Node.js API
* Dockerise an API and PostgreSQL database
* Push Docker images to DockerHub
* Push Docker images to ECR
* Deploy containers to EC2
* Deploy containers to ECS
* Use Secrets Manager
* Build Terraform infrastructure
* Add automated testing stages
* Build a full CI/CD pipeline