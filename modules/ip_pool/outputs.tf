output "id" {
  description = "The resource ID of the IP pool."
  value       = azurerm_network_manager_ip_pool.ip_pool.id
}

output "name" {
  description = "The name of the IP pool."
  value       = azurerm_network_manager_ip_pool.ip_pool.name
}

output "network_manager_id" {
  description = "The resource ID of the Network Manager backing this IP pool."
  value       = azurerm_network_manager.ip_pool.id
}
