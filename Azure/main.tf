terraform {
  required_version = ">= 1.1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Log Analytics workspace (para monitorización / Insights)
resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.resource_group_name}-law"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# AKS
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.node_vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  # Habilitar monitorización con Log Analytics
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  }

  role_based_access_control_enabled = true

  tags = {
    environment = "practica"
  }
}

# Aplica el manifiesto YAML usando az + kubectl
resource "null_resource" "apply_manifest" {
  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command = <<EOT
      # Obtener credenciales del cluster
      az aks get-credentials --resource-group "${azurerm_resource_group.rg.name}" --name "${azurerm_kubernetes_cluster.aks.name}" --overwrite-existing

      # Aplicar manifiesto de la app
      kubectl apply -f "${path.module}/store-demo.yaml"

      # Mostrar servicios para confirmar
      kubectl get svc -o wide
    EOT
  }
}
