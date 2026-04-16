output "id" {
  description = "The resource ID of the Firewall Policy."
  value       = azurerm_firewall_policy.firewall_policy.id
}

output "name" {
  description = "The name of the Firewall Policy."
  value       = azurerm_firewall_policy.firewall_policy.name
}
