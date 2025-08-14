output "resource_group_name" {
  value = azurerm_resource_group.wanderlust.name
  description = "value of the resource group name"
}
output "network_interface_name" {
  value = azurerm_network_interface.main.name
  description = "value of the network interface name"
  
}
output "public_ip_address" {
  value = azurerm_public_ip.main.ip_address
  description = "value of the public IP address"
}

output "private_ip" {
  value = azurerm_network_interface.main.ip_configuration[0].private_ip_address
  description = "value of the private IP address"
  
}


output "client_certificate" {
  value     = azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw

  sensitive = true
}

output "aks_public_ip" {
  value       = azurerm_public_ip.aks_lb_ip.ip_address
  description = "The public IP address attached to the AKS Load Balancer."
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
  description = "The name of the AKS cluster."
  
}
output "aks_node_resource_group" {
  value = azurerm_kubernetes_cluster.aks.node_resource_group
  description = "The resource group where AKS nodes are deployed."
}

output "aks_resource_group_name" {
  value = azurerm_resource_group.wanderlust_aks.name
  description = "The name of the resource group for AKS."
  
}