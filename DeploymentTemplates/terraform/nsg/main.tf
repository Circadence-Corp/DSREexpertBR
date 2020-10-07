provider "azurerm" {
  features {}
}

variable "mgmt_ips" {
  type        = list(string)
  description = "IP addresses to allow rdp into the environment"

  default = []
}

data "azurerm_resource_group" "rg" {
  name = "DefendTheFlag"
}

data "azurerm_network_interface" "nic" {
  for_each            = toset([for n in range(26) : tostring(n)])
  name                = join("", ["Nic", each.value])
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_network_interface" "nic_public" {
  for_each            = toset([for n in range(2) : tostring(n)])
  name                = join("", ["PublicNic", each.value])
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_network_interface" "nic_lariat" {
  name                = "Niclariat"
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_network_security_group" "nsg" {
  name                = "NSG"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "inbound_allow_rdp" {
  name                        = "Allow_RDP"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefixes     = var.mgmt_ips
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "inbound_allow_ssh" {
  name                        = "Allow_SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefixes     = var.mgmt_ips
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_interface_security_group_association" "nsg_assocation" {
  for_each                  = merge(data.azurerm_network_interface.nic, data.azurerm_network_interface.nic_public)
  network_interface_id      = each.value.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface_security_group_association" "nsg_assocation_niclariat" {
  network_interface_id      = data.azurerm_network_interface.nic_lariat.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
