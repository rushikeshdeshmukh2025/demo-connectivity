output "id" {
  description = "The resource ID of the Virtual WAN Hub."
  value       = azurerm_virtual_hub.virtual_wan_hub.id
}

output "name" {
  description = "The name of the Virtual WAN Hub."
  value       = azurerm_virtual_hub.virtual_wan_hub.name
}

output "default_route_table_id" {
  description = "The resource ID of the default route table in the Virtual WAN Hub."
  value       = azurerm_virtual_hub.virtual_wan_hub.default_route_table_id
}
