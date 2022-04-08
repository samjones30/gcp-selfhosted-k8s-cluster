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

## Upgrading the Cluster

### Control plane

1. Drain the node: `kubectl drain k8s-controller --ignore-daemonsets`
2. Upgrade kubeadm: `apt-get update && apt-get install -y --allow-change-held-packages kubeadm=<version>`
3. Plan the control plane upgrade: `kubeadm upgrade plan <version>`
4. Apply the kubeadm upgrade to the control plane: `kubeadm upgrade apply <version>`
5. Upgrade kubelet: `apt-get update && apt-get install -y --allow-change-held-packages kubelet=<version>`
6. Upgrade kubectl: `apt-get update && apt-get install -y --allow-change-held-packages kubectl=<version>`
7. Reload the daemon: `systemctl daemon-reload`
8. Restart kubelet: `systemctl restart kubelet`
9. Uncordon the node: `kubectl uncordon k8s-controller`

### Worker nodes

From the control node, drain the worker node: `kubectl drain <worker_node> --ignore-daemonsets`

Now go to the worker node:

1. Upgrade kubeadm: `apt-get update && apt-get install -y --allow-change-held-packages kubeadm=<version>`
2. Upgrade the node: `kubeadm upgrade node`
3. Upgrade kubelet: `apt-get update && apt-get install -y --allow-change-held-packages kubelet=<version>`
4. Upgrade kubectl: `apt-get update && apt-get install -y --allow-change-held-packages kubectl=<version>`
5. Reload the daemon: `systemctl daemon-reload`
6. Restart kubelet: `systemctl restart kubelet`

Finally from the control node, uncordon the node `kubectl uncordon <worker_node>`
