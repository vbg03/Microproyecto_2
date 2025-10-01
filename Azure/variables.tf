variable "resource_group_name" {
  type    = string
  default = "GrupoParcial"
}

variable "location" {
  type    = string
  default = "canadacentral"
}

variable "cluster_name" {
  type    = string
  default = "ClusterParcial"
}

variable "dns_prefix" {
  type    = string
  default = "aksdemo"
}

variable "node_count" {
  type    = number
  default = 2
}

variable "node_vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}
