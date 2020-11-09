variable "resource_group_name" {
  type = string
}

variable "virtual_network_name" {
  type = string
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to include on resources"
}

variable "lariat_ip" {
  type = string
}

variable "lariat_vhd_uri" {
  type = string
}

variable "lariat_vhd_storage_account_name" {
  type        = string
  description = "The storage account where the lariat vhd is stored."
}

variable "dns_server" {
  type        = string
  description = "Typically the internal ip of the domain controller. Will be applied to the network interface."
}
