resource "azurerm_container_registry" "acr" {
  name                = "acracsapp${var.resourceNaming.environment}"
  resource_group_name = var.resourceGroup
  location            = var.location
  sku                 = "Premium"
  admin_enabled       = true
}

output "acrName" {
    value = azurerm_container_registry.acr.name
}