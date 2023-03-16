resource "azurerm_mssql_server" "mssql" {
  name                = "sqls-euw-acsapp-${var.resourceNaming.environment}"
  resource_group_name = var.resourceGroup
  location            = var.location

  version                       = "12.0"
  public_network_access_enabled = true
  minimum_tls_version           = "1.2"

  azuread_administrator {
    login_username              = var.sqlAADAdminGroup.displayName
    object_id                   = var.sqlAADAdminGroup.objectId
    tenant_id                   = var.tenantId
    azuread_authentication_only = true
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_mssql_firewall_rule" "example" {
  name             = "AllowAcsInbound"
  server_id        = azurerm_mssql_server.mssql.id
  start_ip_address = data.dns_a_record_set.cognitiveSearchHostname.addrs[0]
  end_ip_address   = data.dns_a_record_set.cognitiveSearchHostname.addrs[0]
}

resource "azurerm_mssql_database" "sqldb" {
  name            = "sqldb-euw-acsapp-${var.resourceNaming.environment}"
  server_id       = azurerm_mssql_server.mssql.id
}

resource "azurerm_role_assignment" "sqlServerRoleAssignmentAcs" {
  scope                = azurerm_mssql_server.mssql.id
  role_definition_name = "Reader"
  principal_id         = data.azurerm_search_service.cognitiveSearchData.identity[0].principal_id
}

resource "azuread_group_member" "addDirectoryReaderRole" {
  group_object_id  = "eba8202e-0c59-49ec-af39-3827a4bf35f0"
  member_object_id = azurerm_mssql_server.mssql.identity.0.principal_id
}

output "sqlFqdn" {
    value = azurerm_mssql_server.mssql.fully_qualified_domain_name
}

output "sqlResourceId" {
    value = azurerm_mssql_server.mssql.id
}

output "sqlResourceName" {
    value = azurerm_mssql_server.mssql.name
}

output "dbResourceId" {
    value = azurerm_mssql_database.sqldb.id
}

output "dbResourceName" {
    value = azurerm_mssql_database.sqldb.name
}




# Terraform module reference
/*
module "sqlserver" {
    source = "../../tf-module-repository/modules/sqlserver"
    alternativ:
    source = "https://gitref"
    name                = "sqls-euw-acsapp"
    resource_group_name = var.resourceGroup
    location            = var.location
}*/
