resource "azurerm_service_plan" "asp" {
  name                = "asp-euw-shared-${var.resourceNaming.environment}"
  resource_group_name = var.resourceGroup
  location            = var.location
  os_type             = "Linux"
  sku_name            = "P1v2"
}

resource "azurerm_linux_web_app" "aas" {
  name                = "aas-euw-az400-${var.resourceNaming.environment}"
  resource_group_name = var.resourceGroup
  location            = var.location
  service_plan_id     = azurerm_service_plan.asp.id

  app_settings = {
    "SearchServiceUri" = "https://acs-euw-app-${var.resourceNaming.environment}.search.windows.net"
    "TenantId"         = "${var.tenantId}"
    "AppObjectId"      = "${var.appRegistration.appId}"
    # Dont do this!
    "AppSecret"                                       = "wwI8Q~DJTtHdARau2neIwvzgLQEBR1alHoTwIcNW"
    "DiagnosticServices_EXTENSION_VERSION"            = "~3"
    "InstrumentationEngine_EXTENSION_VERSION"         = "disabled"
    "SnapshotDebugger_EXTENSION_VERSION"              = "disabled"
    "XDT_MicrosoftApplicationInsights_BaseExtensions" = "disabled"
    "XDT_MicrosoftApplicationInsights_Mode"           = "recommended"
    "XDT_MicrosoftApplicationInsights_PreemptSdk"     = "disabled"
    #"DOCKER_CUSTOM_IMAGE_NAME"                        = "acsapp/latest"
    "DOCKER_REGISTRY_SERVER_PASSWORD"                 = azurerm_container_registry.acr.admin_password
    #"DOCKER_REGISTRY_SERVER_URL"                      = azurerm_container_registry.acr.login_server
    "DOCKER_REGISTRY_SERVER_USERNAME"                 = azurerm_container_registry.acr.admin_username
  }

  site_config {
    application_stack {
      docker_image     = "${azurerm_container_registry.acr.name}.azurecr.io/acsapp"
      docker_image_tag = "latest"
    }
  }
}

output "aasOutboundIps" {
  value = azurerm_linux_web_app.aas.outbound_ip_addresses
}

output "aasName" {
  value = azurerm_linux_web_app.aas.name
}

/*
resource "azuread_service_principal_password" "appSecret" {
  service_principal_id = var.appRegistration.objectId
  display_name = "ACS Access Secret"
}*/
