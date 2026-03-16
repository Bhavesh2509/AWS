# Command History and Execution Steps

This section documents the actual commands used during the setup and deployment of the Kubernetes cluster on Amazon EKS.

---

# Install kubectl

Download the Kubernetes CLI tool.

```bash
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/kubectl
```

Make the binary executable.

```bash
chmod +x ./kubectl
```

Move the binary to a global path.

```bash
sudo mv ./kubectl /usr/local/bin
```

Verify installation.

```bash
kubectl version --short --client
```

---

# Install eksctl

Download and install the EKS cluster management tool.

```bash
curl --silent --location \
"https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" \
| tar xz -C /tmp
```

Move it to a system path.

```bash
sudo mv /tmp/eksctl /usr/local/bin
```

Verify installation.

```bash
eksctl version
```

---

# Create EKS Cluster

Create a Kubernetes cluster with worker nodes.

```bash
sudo eksctl create cluster \
--name ecs-app-cluster \
--region us-east-1 \
--nodegroup-name nodes \
--node-type t3.medium \
--nodes 2
```

This command automatically creates:

• EKS control plane
• Worker nodes
• Networking resources
• Security groups
• CloudFormation stack

---

# Configure kubectl to Access Cluster

Configure the local kubeconfig file to connect to the EKS cluster.

```bash
aws eks update-kubeconfig --region us-east-1 --name ecs-app-cluster
```

Verify connection.

```bash
kubectl get nodes
```

Expected result

```
2 nodes Ready
```

---

# List Existing EKS Clusters

Used to confirm that the cluster was successfully created.

```bash
aws eks list-clusters --region us-east-1
```

---

# Deploy Application to Kubernetes

Create deployment and service configuration files.

```bash
touch dep.yaml
touch service.yaml
```

Edit configuration files.

```bash
vi dep.yaml
vi service.yaml
```

---

# Apply Deployment

Deploy the application to the Kubernetes cluster.

```bash
kubectl apply -f dep.yaml
```

Verify pods.

```bash
kubectl get pods
```

---

# Create Kubernetes Service

Expose the application through a load balancer.

```bash
kubectl apply -f service.yaml
```

Check service status.

```bash
kubectl get svc
```

---

# Inspect Kubernetes Resources

Check running pods with additional details.

```bash
kubectl get pods -o wide
```

View labels associated with pods.

```bash
kubectl get pods --show-labels
```

List all cluster resources.

```bash
kubectl get all
```

Check deployments.

```bash
kubectl get deployment
```

---

# Debugging Service Issues

Inspect the service configuration.

```bash
kubectl describe svc ecs-app-service
```

Inspect deployment configuration.

```bash
kubectl describe deployment ecs-app
```

These commands were used to diagnose issues such as:

• Missing pod labels
• Service selectors not matching pods
• Load balancer not routing traffic
• Pods not starting correctly

---

# Result

After deployment:

1. Pods were successfully created in the EKS cluster.
2. Kubernetes service created an AWS load balancer.
3. The application became accessible through the load balancer DNS.
