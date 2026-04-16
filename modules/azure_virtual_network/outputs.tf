output "id" {
  description = "The resource ID of the Virtual Network."
  value       = azurerm_virtual_network.virtual_network.id
}

output "name" {
  description = "The name of the Virtual Network."
  value       = azurerm_virtual_network.virtual_network.name
}

output "subnet_ids" {
  description = "Map of subnet logical keys to subnet resource IDs."
  value       = { for k, s in azurerm_subnet.subnet : k => s.id }
}

output "subnet_names" {
  description = "Map of subnet logical keys to subnet names."
  value       = { for k, s in azurerm_subnet.subnet : k => s.name }
}
