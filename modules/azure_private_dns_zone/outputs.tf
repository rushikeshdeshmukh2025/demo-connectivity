output "id" {
  description = "The resource ID of the Private DNS Zone."
  value       = azurerm_private_dns_zone.private_dns_zone.id
}

output "name" {
  description = "The name of the Private DNS Zone."
  value       = azurerm_private_dns_zone.private_dns_zone.name
}
