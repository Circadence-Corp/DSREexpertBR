provider "azurerm" {
  features {}
}

module "lariat" {
  source                          = "../modules/dtf_lariat"
  resource_group_name             = "DefendTheFlag"
  virtual_network_name            = "DefendTheFlag-vNet"
  lariat_ip                       = "10.0.24.51"
  lariat_vhd_uri                  = "https://lariatvhdsa.blob.core.windows.net/vhd/lariat971.vhd"
  lariat_vhd_storage_account_name = "lariatvhdsa"
  dns_server                      = "10.0.24.4"
  tags = {
    Description = "ihockett - testing with terraform"
  }
}

output "lariat_public_ip" {
  value = module.lariat.lariat_public_ip
}
