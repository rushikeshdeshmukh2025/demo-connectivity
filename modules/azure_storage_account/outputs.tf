output "id" {
  description = "The resource ID of the Storage Account."
  value       = azurerm_storage_account.storage_account.id
}

output "name" {
  description = "The name of the Storage Account."
  value       = azurerm_storage_account.storage_account.name
}

output "primary_blob_endpoint" {
  description = "The primary blob endpoint URL of the Storage Account."
  value       = azurerm_storage_account.storage_account.primary_blob_endpoint
}
