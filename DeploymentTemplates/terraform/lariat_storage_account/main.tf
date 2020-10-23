provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "rg" {
  name = "DefendTheFlag"
}

resource "azurerm_storage_account" "lariat" {
  name                     = "lariatvhdsa"
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
}


resource "azurerm_storage_container" "lariat" {
  name                  = "vhd"
  storage_account_name  = azurerm_storage_account.lariat.name
  container_access_type = "private"
}
