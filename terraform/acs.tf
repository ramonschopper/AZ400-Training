# Create role assignment for App Registration in Search Service
resource "azurerm_role_assignment" "appRegRoleAssignment" {
  scope                = azurerm_search_service.search.id
  role_definition_name = "Search Index Data Reader"
  principal_id         = var.appRegistration.principalId # App Registration Identity
}

resource "azurerm_role_assignment" "scRoleAssignment" {
  scope                = azurerm_search_service.search.id
  role_definition_name = "Search Index Data Contributor"
  principal_id         = var.ownerObjectId
}


resource "azurerm_search_service" "search" {
  name                          = "acs-euw-app-${var.resourceNaming.environment}"
  resource_group_name           = var.resourceGroup
  location                      = var.location
  sku                           = "standard"
  partition_count               = 1
  replica_count                 = 1
  public_network_access_enabled = true
  allowed_ips                   = azurerm_linux_web_app.aas.outbound_ip_address_list
  tags                          = var.tags

  identity {
    type = "SystemAssigned"
  }

  timeouts {
    create = "60m"
  }
}

data "azurerm_subscription" "current" {}

resource "null_resource" "authOptions" {
  triggers = {
    resourceGroup = var.resourceGroup
  }
  provisioner "local-exec" {
    when        = create
    interpreter = ["pwsh", "-NoLogo", "-NoProfile", "-NonInteractive", "-command"]
    command     = <<-EOC
      ${path.module}/hook_azlogin.ps1
      $uri = "https://management.azure.com/subscriptions/${var.subscriptionId}/resourcegroups/${self.triggers.resourceGroup}/providers/Microsoft.Search/searchServices/${azurerm_search_service.search.name}?api-version=2021-04-01-Preview"
     
      $body = @{
        location   = "${var.location}"
        sku        = @{
            'name' = "standard"
        }
        properties = @{
            authOptions = @{
              aadOrApiKey = @{
                  'aadAuthFailureMode' = "http401WithBearerChallenge"
              }
            }
        }
      } | ConvertTo-Json -Compress -Depth 100

      $body = $body -replace "`"", "\`"" -replace ":\\", ": \"

      Write-Host "##[command] Setting "AuthOptions" to "aadOrApiKey" to enable Azure AD authentication..."
      az rest --method patch --url $uri --headers "Content-Type=application/json" --body $body
    EOC
  }

  depends_on = [azurerm_search_service.search]
}


output "acsName" {
    value = azurerm_search_service.search.name
}