terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.54.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "42bfbd55-9cf7-4908-9ab0-d693ea84b4e6"
}

resource "random_integer" "unique_id" {
  min = 10000
  max = 99999
}

resource "azurerm_resource_group" "azure_rg" {
  name     = "${var.resource_group_name}${random_integer.unique_id.result}"
  location = var.resource_group_location
}

resource "azurerm_service_plan" "azure_sp" {
  name                = "${var.app_service_plan_name}${random_integer.unique_id.result}"
  location            = azurerm_resource_group.azure_rg.location
  resource_group_name = azurerm_resource_group.azure_rg.name
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_mssql_server" "azure_sql" {
  name                         = "${var.sql_server_name}${random_integer.unique_id.result}"
  resource_group_name          = azurerm_resource_group.azure_rg.name
  location                     = azurerm_resource_group.azure_rg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password
}

resource "azurerm_mssql_firewall_rule" "azure_firewall" {
  name             = var.firewall_rule_name
  server_id        = azurerm_mssql_server.azure_sql.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_mssql_database" "azure_db" {
  name           = "${var.sql_database_name}${random_integer.unique_id.result}"
  server_id      = azurerm_mssql_server.azure_sql.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 2
  sku_name       = "S0"
  zone_redundant = false

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_linux_web_app" "azure_webapp" {
  name                = "${var.app_service_name}${random_integer.unique_id.result}"
  resource_group_name = azurerm_resource_group.azure_rg.name
  location            = azurerm_service_plan.azure_sp.location
  service_plan_id     = azurerm_service_plan.azure_sp.id

  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Data Source=tcp:${azurerm_mssql_server.azure_sql.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.azure_db.name};User ID=${azurerm_mssql_server.azure_sql.administrator_login};Password=${azurerm_mssql_server.azure_sql.administrator_login_password};Trusted_Connection=False; MultipleActiveResultSets=True;"
  }

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
    always_on = false
  }
}

resource "azurerm_app_service_source_control" "github" {
  app_id                 = azurerm_linux_web_app.azure_webapp.id
  repo_url               = var.github_repo_url
  branch                 = "main"
  use_manual_integration = true
}