variable "project_id" {}

variable "project_name" {
  default = "k8s-cluster"
}

variable "k8s_nodes" {
  description = "Map of K8s node configuration"
  type        = map(any)
}