data "azurerm_client_config" "current"{}

#Random String for suffix
resource "random_string" "suffix" {
    length  = 8
    special = false
    upper   = false
    numeric = true

    lifecycle {
        ignore_changes = [ length, special, upper, numeric ]
    } 
}

resource "azurerm_resource_group" "wanderlust_aks" {
  name     = "${var.env}-wanderlust-resources"
  location = "East US"
  
}
# resource "azurerm_container_registry" "acr" {
#   name                = "containerRegistry1"
#   resource_group_name = azurerm_resource_group.wanderlust.name
#   location            = azurerm_resource_group.wanderlust.location
#   sku                 = "Standard"
#   admin_enabled       = true
# }

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-wanderlust"
  location            = azurerm_resource_group.wanderlust_aks.location
  resource_group_name = azurerm_resource_group.wanderlust_aks.name
  dns_prefix          = "aks-wanderlust-${var.env}"

  node_resource_group = "aks-wanderlust-nodes"

  #Add timeout
    timeouts {
        create = "30m"
        update = "30m"
        delete = "30m"
    }

  default_node_pool {
    name            = "default"
    os_disk_size_gb = 30
    node_count      = 1
    vm_size         = "Standard_D2s_v3"

    #Automatic scaling
    # auto_scaling_enabled = false
    # min_count            = 1
    # max_count            = 3
  }

  # Conditional SSH key configuration
  dynamic "linux_profile" {
    for_each = fileexists("${path.module}/wanderlust-key.pub") ? [1] : []
    content {
      admin_username = "azureuser"

      ssh_key {
        key_data = file("${path.module}/wanderlust-key.pub")
      }
    }
  }

  identity {
    type = "SystemAssigned"
  }

  azure_active_directory_role_based_access_control {
    tenant_id = data.azurerm_client_config.current.tenant_id
    azure_rbac_enabled = false
  }
  # Network configuration for better stability
  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
  }

  # Ignore changes to kubernetes_version to prevent unwanted upgrades
  lifecycle {
    ignore_changes = [
      kubernetes_version,
      default_node_pool[0].orchestrator_version
    ]
  }

  tags = {
    Environment = "${var.env}-wanderlust-aks"
  }
}
# Public IP for the AKS Load Balancer
resource "azurerm_public_ip" "aks_lb_ip" {
  name                = "aks-wanderlust-public-ip"
  location            = azurerm_resource_group.wanderlust_aks.location
  resource_group_name = azurerm_kubernetes_cluster.aks.node_resource_group
  allocation_method   = "Static"
  sku                 = "Standard"

  depends_on = [azurerm_kubernetes_cluster.aks]
}


# Role assignment for the current user to have admin access to the cluster
resource "azurerm_role_assignment" "aks_admin" {
  scope                = azurerm_kubernetes_cluster.aks.id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Role assignment for the AKS managed identity to pull images from ACR (if using ACR)
# resource "azurerm_role_assignment" "aks_acr_pull" {
#   count                = 0 # Enable this if you're using ACR
#   scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
#   role_definition_name = "AcrPull"
#   principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
# }

# Role assignment for cluster managed identity to manage cluster resources
resource "azurerm_role_assignment" "aks_identity_operator" {
  scope                = azurerm_resource_group.wanderlust_aks.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}

# Role assignment for cluster managed identity to manage network resources
resource "azurerm_role_assignment" "aks_network_contributor" {
  scope                = azurerm_resource_group.wanderlust_aks.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}

# Wait for cluster to be fully ready before proceeding with Kubernetes resources
resource "time_sleep" "wait_for_cluster" {
  depends_on = [
    azurerm_kubernetes_cluster.aks,
    azurerm_role_assignment.aks_admin,
    azurerm_role_assignment.aks_identity_operator,
    azurerm_role_assignment.aks_network_contributor
  ]
  create_duration = "60s" # Wait 60 seconds for cluster and RBAC to be ready
}

