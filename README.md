# Google Kubernetes Cluster

Learning cluster, deployed to three instances. This is a fully self managed cluster, not using GKE.

## Deploy the Infrastructure

1. Authenticate to GCloud - `gcloud auth application-default login`
2. Initialise the Terraform - `terraform init`
3. Apply the Terraform - `terraform apply`

## Deploy the Cluster

### Initialize the Cluster

On the controller node:

1. Initialize the Kubernetes cluster on the control plane node using kubeadm: `kubeadm init --pod-network-cidr 192.168.0.0/16 --kubernetes-version 1.23.0`
2. Create the K8s config file as root: `export KUBECONFIG=/etc/kubernetes/admin.conf`
3. Test access to cluster: `kubectl get nodes`
4. On the Control Plane Node, install Calico Networking: `kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml`
5. Create the join token and copy the kubeadm join command: `kubeadm token create --print-join-command`

### Join worker nodes to Cluster

Using the token from above, execute this on each of the worker nodes.
