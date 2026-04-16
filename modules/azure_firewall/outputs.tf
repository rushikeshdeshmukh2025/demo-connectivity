output "id" {
  description = "The resource ID of the Azure Firewall."
  value       = azurerm_firewall.firewall.id
}

output "name" {
  description = "The name of the Azure Firewall."
  value       = azurerm_firewall.firewall.name
}

output "private_ip_address" {
  description = "The private IP address of the Azure Firewall."
  value       = azurerm_firewall.firewall.virtual_hub[0].private_ip_address
}
