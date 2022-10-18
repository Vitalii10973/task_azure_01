terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
  backend "azurerm" {
        resource_group_name  = "terraform-rg"
        storage_account_name = "terraformstorage10973"
        container_name       = "sktfcontainer"
        key                  = "tf/terraform.tfstate"
    }
}

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "prod_app_rg" {
  name     = "my-Web-App_109"
  location = "East US"
}

resource "azurerm_storage_account" "my_storage_account" {
  name                     = "mysrorageaccount10973"
  resource_group_name      = azurerm_resource_group.prod_app_rg.name
  location                 = azurerm_resource_group.prod_app_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_mssql_server" "my_mssql_server" {
  name                         = "my-mssql-server-109"
  resource_group_name          = azurerm_resource_group.prod_app_rg.name
  location                     = azurerm_resource_group.prod_app_rg.location
  version                      = "12.0"
  administrator_login          = "vitalii10973"
  administrator_login_password = "Dsnfksr2022"
}

resource "azurerm_mssql_database" "my_mssql_database" {
  name           = "my-db-1"
  server_id      = azurerm_mssql_server.my_mssql_server.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 2
  read_scale     = false
  sku_name       = "Basic"
  zone_redundant = false

  tags = {
    foo = "bar"
  }

  depends_on = [
     azurerm_mssql_server.my_mssql_server
   ]

}

resource "azurerm_mssql_database_extended_auditing_policy" "extended_auditing_policy101" {
  database_id                             = azurerm_mssql_database.my_mssql_database.id
  storage_endpoint                        = azurerm_storage_account.my_storage_account.primary_blob_endpoint
  storage_account_access_key              = azurerm_storage_account.my_storage_account.primary_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = 6
}

resource "azurerm_mssql_firewall_rule" "app_server_firewall_rule_Allow_Azure_services" {
  name             = "app-server-firewall-rule-Allow-Azure-services"
  server_id        = azurerm_mssql_server.my_mssql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
  depends_on = [
     azurerm_mssql_server.my_mssql_server
   ]
}

resource "azurerm_mssql_firewall_rule" "app_server_firewall_rule_Client_IP" {
  name             = "app-server-firewall-rule-Client-IP"
  server_id        = azurerm_mssql_server.my_mssql_server.id
  start_ip_address = "188.163.114.159"
  end_ip_address   = "188.163.114.159"
  depends_on = [
     azurerm_mssql_server.my_mssql_server
   ]
}

resource "azurerm_service_plan" "serviceplan" {
  name                = "my-webapp-sp"
  resource_group_name = azurerm_resource_group.prod_app_rg.name
  location            = azurerm_resource_group.prod_app_rg.location
  os_type             = "Windows"
  sku_name            = "B1"
  depends_on = [
     azurerm_mssql_database.my_mssql_database
   ]
}

resource "azurerm_windows_web_app" "my_webapp" {
  name                = "my-WebApp-10973363"
  resource_group_name = azurerm_resource_group.prod_app_rg.name
  location            = azurerm_service_plan.serviceplan.location
  service_plan_id     = azurerm_service_plan.serviceplan.id

  site_config {
    application_stack {
      current_stack = "dotnet"
      dotnet_version = "v6.0"
    }
  }
  connection_string {
    name  = "my-db-1"
    type  = "SQLServer"
    value = "Server=tcp:my-mssql-server-109.database.windows.net,1433;Initial Catalog=my-db-1;Persist Security Info=False;User ID=vitalii10973;Password=Dsnfksr2022;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  }
  depends_on = [
     azurerm_service_plan.serviceplan
   ]
}
