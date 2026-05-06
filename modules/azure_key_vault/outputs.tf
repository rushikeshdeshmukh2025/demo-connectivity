output "id" {
  description = "The resource ID of the Key Vault."
  value       = azurerm_key_vault.key_vault.id
}

output "name" {
  description = "The name of the Key Vault."
  value       = azurerm_key_vault.key_vault.name
}

output "vault_uri" {
  description = "The URI of the Key Vault."
  value       = azurerm_key_vault.key_vault.vault_uri
}
