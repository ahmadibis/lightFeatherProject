# LightFeather Challenge

This project demonstrates the deployment of a React frontend and an Express backend to AWS using Terraform, Docker(ECR), and Jenkins for CI/CD. The infrastructure includes an AWS ECS cluster to host the applications, and Jenkins to automate deployments.

## **Project Overview** 

This repository contains:
- A **React frontend** and an **Express backend**.
- A **Jenkins pipeline** for automated deployment.
- **Terraform scripts** to provision the required AWS infrastructure.
- **Dockerized applications** running on AWS ECS.

## **Setup & Installation**

### **Prerequisites**
Ensure you have the following installed before proceeding:
- [Node.js 16+](https://nodejs.org/en/download/)
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [Docker](https://docs.docker.com/get-docker/)
- [AWS CLI](https://aws.amazon.com/cli/) (Configured with appropriate IAM permissions)

## **Deployment Overview**

The following components are deployed:
1. **Jenkins Server**: Manually set up in AWS to handle CI/CD.
    - Configure Jenkins to Pull the Project Repository
    - Installed the necessary plugins (Docker Pipeline, Amazon EC2 Plugin, and Pipeline Utility Steps)
    - Setup AWS Iam roles for jenkins:
        - Create an IAM role in AWS that Jenkins will use to interact with ECS, ECR, and other resources.
        - Attach the following policies to the role:
            - AmazonEC2FullAccess
            - AmazonECS_FullAccess
            - AmazonECRFullAccess
2. **Frontend & Backend Services**:
   - Containerized and deployed to AWS ECS.
   - Exposed via a load balancer for public access.
3. **Terraform Infrastructure**:
   - ECS Cluster, Services, and Tasks.
   - Networking components (VPC, Subnets, Security Groups).
   - IAM roles for necessary permissions.

## **Deploying with Jenkins**
The Jenkins pipeline automates the following steps:
- Build Docker images for the frontend and backend.
- Push the images to AWS Elastic Container Registry (ECR).
- Update the ECS task definitions.
- Deploy new containers to AWS ECS.
- The Jenkins job can be triggered manually, but it is also setup to do automatic deployment on new commits.

## **Accessing the Applications**
**you can access the application through following URLs** :

- Frontend URL: http://YOUR_FRONTEND_PUBLIC_URL