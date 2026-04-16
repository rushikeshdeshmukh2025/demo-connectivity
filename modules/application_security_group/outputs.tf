output "id" {
  description = "The resource ID of the Application Security Group."
  value       = azurerm_application_security_group.asg.id
}

output "name" {
  description = "The name of the Application Security Group."
  value       = azurerm_application_security_group.asg.name
}
