output "id" {
  description = "The resource ID of the Private Endpoint."
  value       = azurerm_private_endpoint.private_endpoint.id
}

output "name" {
  description = "The name of the Private Endpoint."
  value       = azurerm_private_endpoint.private_endpoint.name
}

output "private_ip_address" {
  description = "The private IP address assigned to the Private Endpoint network interface."
  value       = azurerm_private_endpoint.private_endpoint.private_service_connection[0].private_ip_address
}
