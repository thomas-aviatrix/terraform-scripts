# specify aviatrix as the provider with these parameters:
# controller_ip - public IP address of the controller
# username - login user name, default is admin
# password - password

provider "azurerm" {
    # The "feature" block is required for AzureRM provider 2.x.
    # If you're using version 1.x, the "features" block is not allowed.
    version = "~>2.0"
    features {}
    subscription_id = "834787f1-bb9a-4c4c-8622-3acfecb5481f"
    tenant_id       = "a063e36b-33b8-4031-964a-10e21b0b4d94"
    client_id       = "8ca0e610-b26d-4371-9262-8f19cb7937c6"
    client_secret   = var.client_secret
}


resource "azurerm_resource_group" "cloudN_ER_RG" {
    name     = "thomas-ER-RG"
    location = "Southeast Asia"

    tags = {
        environment = "ExpressRoute"
    }
}

#To get the service_key
#############################
resource "azurerm_express_route_circuit" "cloudN_demo" {
  name                  = "thomas-cloudN-demo-ExpressRoute"
  resource_group_name   = azurerm_resource_group.cloudN_ER_RG.name
  location              = azurerm_resource_group.cloudN_ER_RG.location
  service_provider_name = "Equinix"
  peering_location      = "Silicon Valley"
  bandwidth_in_mbps     = 50
  sku {
    tier   = "Standard"
    family = "MeteredData"
  }
  allow_classic_operations = false
}

output "cloudN_demo_service_key" {
  value = azurerm_express_route_circuit.cloudN_demo.service_key
}

output "cloudN_demo_circuit_id" {
  value = azurerm_express_route_circuit.cloudN_demo.id
}

output "cloudN_demo_circuit_name" {
  value = azurerm_express_route_circuit.cloudN_demo.name
}


#To configure ER
#############################
resource "azurerm_express_route_circuit_peering" "er_peering" {
  peering_type                  = "AzurePrivatePeering"
  express_route_circuit_name    = azurerm_express_route_circuit.cloudN_demo.name
  resource_group_name           = azurerm_resource_group.cloudN_ER_RG.name
  peer_asn                      = var.bgp_asn
  primary_peer_address_prefix   = var.azure_peer_prefix_pri
  secondary_peer_address_prefix = var.azure_peer_prefix_sec
  vlan_id                       = var.vlan_id
}


resource "azurerm_virtual_network_gateway_connection" "vng_connection" {
  name                       = "cloudN-5"
  location                   = var.transit_vnet_region
  resource_group_name        = var.transit_vnet_resource_group
  type                       = "ExpressRoute"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vng.id
  express_route_circuit_id   = azurerm_express_route_circuit.cloudN_demo.id
 
  depends_on = [azurerm_express_route_circuit_peering.er_peering]
}

resource "azurerm_subnet" "vng_gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.transit_vnet_resource_group
  virtual_network_name = var.transit_vnet_name
  address_prefixes     = var.transit_vnet_gw_subnet_cidr
}
 
resource "azurerm_public_ip" "vng" {
  name                = "vng"
  location            = var.transit_vnet_region
  resource_group_name =  var.transit_vnet_resource_group
  allocation_method   = "Dynamic"
}
 
resource "azurerm_virtual_network_gateway" "vng" {
  name                = "cloudN-vng"
  location            = var.transit_vnet_region
  resource_group_name =  var.transit_vnet_resource_group
  type     = "ExpressRoute"
  vpn_type = "RouteBased"
  sku      = "Standard" # try "High performance" for perf tests
 
  ip_configuration {
    public_ip_address_id          = azurerm_public_ip.vng.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.vng_gateway.id
  }
}
 



