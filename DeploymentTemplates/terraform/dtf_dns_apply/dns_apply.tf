provider "azurerm" {
  features {}
}

module "dns" {
  source               = "../modules/dtf_dns"
  resource_group_name  = "DefendTheFlag"
  virtual_network_name = "DefendTheFlag-vNet"
  domain_name          = "bronerg.tk"
  tags = {
    Description = "ihockett - testing with terraform"
  }
}
