
variable "client_secret" {
  type = string
  default = "nxxxxxxxxxxxxxxxxxxxxx"
}

variable "vlan_id" {
  type = string
  default = "805"
}


variable "bgp_asn" {
  type = string
  default = "65000"
}

variable "azure_peer_prefix_pri" {
  type = string
  default = "10.255.255.0/30"
}

variable "azure_peer_prefix_sec" {
  type = string
  default = "10.255.254.0/30"
}

variable "transit_vnet_name" {
  type = string
  default = "thomas-azure-transit-eastus2"
}

variable "transit_vnet_region" {
  type = string
  default = "East US 2"
}

variable "transit_vnet_resource_group" {
  type = string
  default = "rg-av-thomas-azure-transit-eastus2-173664"
}

variable "transit_vnet_gw_subnet_cidr" {
  type = list
  default = ["10.78.96.0/26"]
}

