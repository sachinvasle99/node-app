# Node js app infra and ci/cd setup

This is a Node.js web application that exposes a RESTful API with status and data endpoints. It includes a CI/CD pipeline using GitHub Actions to automate the building, and deployment processes.

## Pre-requisites to run the application locally
   configure the postgresql database & redis server on local

## Prerequisites on local
- postgresql database
- redis server

## Local Setup

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/your-username/your-repo.git
   cd your-repo

2. **Install Dependencies:**
   ```bash
   npm init

3. **Run the index.js**
   ```bash
   node index.js

4. **Output should be like this**
   ```bash
   Server listening on port 3000

5. **Test the API Endpoints**
   ```bash  
   curl http://localhost:3000/status

   Send the request and verify that you receive a JSON response with a status of "OK".
   
   For the POST /data endpoint, set the HTTP method to POST and the URL to

   curl -X POST http://localhost:3000/data -H "Content-Type: application/json" -d '{ "data": "Hello from Mac M1" }'

   Send the request and verify that you receive a message
   {"message":"Data stored successfully"}%   

## AWS Infrastructure
The AWS infrastructure is provisioned using Terraform. It includes:

1. VPC
2. Aurora postgres serveless v2 cluster
3. EKS cluster
4. ECR registry
5. Node group
6. Security Group 

**Instructions:**

Before deploying the AWS infra, Create RDS credentials in AWS Secrets Manager with "nodeapp_aurora_serverless_password" as id and store the RDS password as its value.

As you can see terraform block in the aurora-psql.tf, we are passing the RDS pass from secrets manager
```console
data "aws_secretsmanager_secret_version" "serverless_creds" {
  secret_id = "nodeapp_aurora_serverless_password"
}

locals {
  rds_password = jsondecode(
    data.aws_secretsmanager_secret_version.serverless_creds.secret_string
  )
}
```


To deploy the infrastructure manually, follow these steps:
1. Ensure you have the AWS CLI installed and configured.
2. Navigate to the terraform/ directory.
3. Run the following commands:
   ```bash
   terraform init
   terraform plan
   terraform apply

## CI/CD Pipeline for Terraform Infrastructure Changes

This repository includes a CI/CD pipeline using GitHub Actions to manage Terraform infrastructure changes.

**Securing Secrets :**

Ensure that your AWS credentials are stored securely as GitHub secrets. To add these secrets:

Navigate to your GitHub repository.

Go to "Settings" -> "Secrets" -> "New repository secret."

Add the following secrets:
   ```bash
    AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY
```

Never expose sensitive information directly in the code.

The CI/CD pipeline is triggered on pushes to the `terraform` branch, specifically on changes within the `terraform/` directory. The workflow includes the following steps:

## Helm chart deployment

**Prerequisites**
- Add the EBS CSI drive add ons to the EKS cluster by following steps this 2 steps
1. https://docs.aws.amazon.com/eks/latest/userguide/csi-iam-role.html
2. https://docs.aws.amazon.com/eks/latest/userguide/managing-ebs-csi.html

EBS CSI driver is require for the PVC to bound with storage class.

Helm provides a quick way of setting up a Redis cluster using a pre-made Helm chart.

1. Add the Helm repository containing the Redis chart
   ```bash
   helm repo add bitnami https://charts.bitnami.com/bitnami
2. Update local Helm repositories.
   ```bash
   helm repo update
3. Create a dedicated namespace for Redis (if not already created):
   ``bash
   k create ns redis
4. Use helm install to install the chart. The basic command is as follows:
   ```bash
   helm install my-release bitnami/redis -n redis
5. Once the charts gets deploy, it will show the host and password on the console for redis cluster make sure to note that as wh will need them to create the redis-coonection secret

Create the redis-coonection secret using the following command for node-app helm chart to connect with redis cluster
```bash
k create secret generic redis-connection \
  --from-literal=REDIS_HOST=<VALUE> \
  --from-literal=REDIS_PORT=<VALUE> \
  --from-literal=REDIS_PASSWORD=<VALUE>
```  

As we have already created the Aurora psql database, retrive the username, password and host from the RDS console and create the secrets as follows
```bash
k create secret generic postgres-connection \
  --from-literal=DB_USER=<VALUE> \
  --from-literal=DB_PASSWORD=<VALUE> \
  --from-literal=DB_DATABASE=<VALUE> \
  --from-literal=DB_HOST=<VALUE> \
  --from-literal=DB_PORT=<VALUE>
```
## CI/CD Pipeline for Docker Image Build and Push to ECR
This repository includes a CI/CD pipeline using GitHub Actions to build a Docker image and push it to Amazon ECR and deploy the helmchart to the EKS cluster
The CI/CD pipeline is triggered on pushes to the `main` branch.

This workflow include the same secrets which we have used for terraform workflow.

Deploy the node-app helmchart commiting into the main branch or you can deploy manually as follws
```bash
cd helmchart
helm install nodeapp ./node-app -n development
```
Once the chart gets deploy we can test the api endpoints, first port-forward the node-app svc
```bash
kpf svc/nodeapp-node-app 3000:3000 -n development
```
**Test the API Endpoints**
   ```bash  
   curl http://localhost:3000/status

   Send the request and verify that you receive a JSON response with a status of "OK".
   
   For the POST /data endpoint, set the HTTP method to POST and the URL to

   curl -X POST http://localhost:3000/data -H "Content-Type: application/json" -d '{ "data": "Hello from Mac M1" }'

   Send the request and verify that you receive a message
   {"message":"Data stored successfully"}%  
   ```

## Set up monitoring using Prometheus.

## Get Helm Repository Info
```console
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts 
helm repo update
```

## Install Helm Chart

```console
k create ns monitoring
helm install [RELEASE_NAME] prometheus-community/kube-prometheus-stack -n monitoring
```
Access Prometheus Dashboard

```console
k port-forward -n prom prometheus-prom-kube-prometheus-stack-prometheus-0 9090
```
Now you can access prometheus dashboard on http://localhost:9090

Access Grafana Dashboard:

default user/password is admin/prom-operator

```console
k port-forward -n prom prom-grafana-6c578f9954-rjdmk 3000
```
Now you can access grafana dashboard on http://localhost:3000

## Set up Fluent Bit as a DaemonSet to send logs to CloudWatch Logs
We have already setup EKS Cluster set up with EC2 Worker Nodes
Make sure to attach an IAM Policy(CloudWatchAgentServerPolicy) to workewr nodes’ IAM Role for enabling the Worker Nodes to send metric data to CloudWatch


We need to create a namespace for these components.
```console
K create ns amazon-cloudwatch
```

Run the following command to create a ConfigMap named cluster-info with the cluster name and the Region to send logs to. Replace cluster-name and cluster-region with your cluster's name and Region.

```console
ClusterName=cluster-name
RegionName=cluster-region
FluentBitHttpPort='2020'
FluentBitReadFromHead='Off'
[[ ${FluentBitReadFromHead} = 'On' ]] && FluentBitReadFromTail='Off'|| FluentBitReadFromTail='On'
[[ -z ${FluentBitHttpPort} ]] && FluentBitHttpServer='Off' || FluentBitHttpServer='On'
k create configmap fluent-bit-cluster-info \
--from-literal=cluster.name=${ClusterName} \
--from-literal=http.server=${FluentBitHttpServer} \
--from-literal=http.port=${FluentBitHttpPort} \
--from-literal=read.head=${FluentBitReadFromHead} \
--from-literal=read.tail=${FluentBitReadFromTail} \
--from-literal=logs.region=${RegionName} -n amazon-cloudwatch
```

Download and deploy the Fluent Bit daemonset to the cluster by running one of the following commands.
```console
k apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/fluent-bit/fluent-bit.yaml
```

Validate the deployment by entering the following command. Each node should have one pod named fluent-bit-*.
```console
k get pods -n amazon-cloudwatch
```

Verify the Fluent Bit setup
1. Open the CloudWatch console at https://console.aws.amazon.com/cloudwatch/.
2. In the navigation pane, choose Log groups.
3. Make sure that you're in the Region where you deployed Fluent Bit
4. Check the list of log groups in the Region. You should see the following:
   ```bash
   /aws/containerinsights/Cluster_Name/application
   /aws/containerinsights/Cluster_Name/host
   /aws/containerinsights/Cluster_Name/dataplane
   ```
Navigate to one of these log groups and check the Last Event Time for the log streams. If it is recent relative to when you deployed Fluent Bit, the setup is verified.
There might be a slight delay in creating the /dataplane log group. This is normal as these log groups only get created when Fluent Bit starts sending logs for that log group.   