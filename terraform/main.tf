terraform {
  backend "azurerm" {
    resource_group_name  = "rg-chn-tfstate"
    storage_account_name = "straz400tfstate"
    container_name       = "corporate-web"
    key                  = "state.tfstate"
  }
}

resource "azurerm_resource_group" "base-rg" {
  name     = "rg-chn-webapp-${var.environment}"
  location = var.location
}

resource "azurerm_service_plan" "asp" {
  name                = "asp-euw-shared"
  resource_group_name = azurerm_resource_group.base-rg.name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "P1v2"
}

resource "azurerm_linux_web_app" "aas" {
  name                = "aas-euw-az400"
  resource_group_name = azurerm_resource_group.base-rg.name
  location            = var.location
  service_plan_id     = azurerm_service_plan.asp.id

  site_config {}
}
