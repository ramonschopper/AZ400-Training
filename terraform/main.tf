terraform {
  required_version = "~>1.3.9"
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "~>1.2.17"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.40.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.4.3"
    }
    external = {
      source  = "hashicorp/external"
      version = "~>2.2.3"
    }
    null = {
      source  = "hashicorp/null"
      version = "~>3.2.1"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~>2.36.0"
    }
  }
  backend "azurerm" {}
}

provider "azurerm" {
  subscription_id = var.subscriptionId
  tenant_id       = var.tenantId
  features {}
}

data "http" "azureDevOpsAgentCurrentIP" {
  url = "http://ifconfig.me"
}

# This data object will resolve the public hostname of the Cognitive Search Service to retrieve its IP address which later will be whitelisted in the SQL server
data "dns_a_record_set" "cognitiveSearchHostname" {
  host = "${azurerm_search_service.search.name}.search.windows.net"
}

# This data object is required to retrieve the Principal ID of the System Assigned Managed Identity of the Cogntive Search Service which is not exported upon creation
data "azurerm_search_service" "cognitiveSearchData" {
  depends_on          = [azurerm_search_service.search]
  name                = azurerm_search_service.search.name
  resource_group_name = var.resourceGroup
}

output "acsResourceGroupName" {
  value = var.resourceGroup
}
