subscriptionId = "4c713b6e-2479-48bb-ab84-0b932c0a276b"   # Subscription Id where the deployment will be done
tenantId       = "b8a53dab-10d3-4ab4-8819-d608f0f31883"   # Tenant Id
resourceGroup  = "rg-sample-containerapp-nonprod"       # Resource group where the solution will be deployed
location       = "westeurope"                             # Location where all the resources will be deployed
ownerObjectId  = "52434a9f-5497-4f5e-9c3b-63bf1624eef6"   # ADO service connection

# tags that will be applied for both, certified products and modules

tags = {
  technical_contact = "ramon@schopper.me" # This is a sample of a custom application tag
}

resourceNaming = {
  serviceName = "acsapp" # max 10 characters, layer name or service short name
  environment = "nonprod"
}

# SQL Server config
sqlAADAdminGroup = {
  displayName = "sc-devops"
  objectId    = "52434a9f-5497-4f5e-9c3b-63bf1624eef6"
}

sqlDbGeneralPurposeConfig = {
  resourceName = "sample-books-db" # 1-128 characters, can't use <>*%&:\/? and can't end with period or space
  skuName      = "GP_S_Gen5_1"
  collation    = "SQL_Latin1_General_CP1_CS_AS"
}

acsConfig = {
  allowedIps = "137.117.178.4" # Egress IP for Stratum App Hosting DEV-WE environment
}

# App Registration is required for App Service to access Search Service as API keys are disabled as per security requirement
appRegistration = {
  objectId     = "627ba186-217c-46b0-9c39-040fd2ff3344"
  principalId  = "8293eb0e-6f08-489a-abf4-0b2f147cf892"
  appId        = "d2b1e5ae-f021-44e5-a49b-bf8044b2c6a3"
}