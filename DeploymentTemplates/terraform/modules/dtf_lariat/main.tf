data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "subnet" {
  name                 = data.azurerm_virtual_network.vnet.subnets[0]
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

data "azurerm_storage_account" "sa" {
  name                = var.lariat_vhd_storage_account_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_public_ip" "public_ip" {
  name                = "lariat-pip"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  tags                = var.tags
}

resource "azurerm_network_interface" "nic" {
  name                = "lariat-nic"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  dns_servers         = list(var.dns_server)

  ip_configuration {
    name                          = "lariat-ipconfig"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
    private_ip_address            = var.lariat_ip
  }
}

resource "azurerm_managed_disk" "disk" {
  name                 = "lariat-disk"
  location             = data.azurerm_resource_group.rg.location
  resource_group_name  = data.azurerm_resource_group.rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Import"
  source_uri           = var.lariat_vhd_uri
  storage_account_id   = data.azurerm_storage_account.sa.id
  os_type              = "Linux"
  tags                 = var.tags
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "lariatvm"
  location              = data.azurerm_resource_group.rg.location
  resource_group_name   = data.azurerm_resource_group.rg.name
  vm_size               = "Standard_D2s_v3"
  network_interface_ids = list(azurerm_network_interface.nic.id)
  storage_os_disk {
    name            = azurerm_managed_disk.disk.name
    create_option   = "Attach"
    caching         = "ReadWrite"
    os_type         = "Linux"
    managed_disk_id = azurerm_managed_disk.disk.id
  }
}

data "azurerm_public_ip" "lariat_public_ip" {
  name                = azurerm_public_ip.public_ip.name
  resource_group_name = data.azurerm_resource_group.rg.name
  depends_on = [
    azurerm_public_ip.public_ip,
    azurerm_virtual_machine.vm
  ]
}
