provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "LariatVhdStorage"
  location = "Central US"
}

resource "azurerm_storage_account" "lariat" {
  name                     = "lariatvhdsa"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
}


resource "azurerm_storage_container" "lariat" {
  name                  = "vhd"
  storage_account_name  = azurerm_storage_account.lariat.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "lariat" {
  name                   = "disk-0.vhd"
  storage_account_name   = azurerm_storage_account.lariat.name
  storage_container_name = azurerm_storage_container.lariat.name
  type                   = "Page"
  source_uri             = ""
}
