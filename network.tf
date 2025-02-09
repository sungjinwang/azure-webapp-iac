# Vnet
resource "azurerm_virtual_network" "vnet" {
    name = "vnet-cus"
    address_space = var.address_space
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}

# Subnet
resource "azurerm_subnet" "subnets" {
  for_each = var.subnets
  name                 = each.key
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value.address_prefix]

  # Private subnet 설정
  default_outbound_access_enabled = each.value.outbound
}

# NSG
resource "azurerm_network_security_group" "nsg" {
  for_each            = var.nsgs
  name                = each.key
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  dynamic "security_rule" {
    for_each = each.value.rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_ranges           = security_rule.value.source_port_ranges
      destination_port_ranges      = security_rule.value.destination_port_ranges
      source_address_prefixes      = security_rule.value.source_address_prefixes
      destination_address_prefixes = security_rule.value.destination_address_prefixes
    }
  }
}

# NIC
resource "azurerm_network_interface" "nic" {
  for_each = { for nic in var.nic_configs : nic.name => nic }

  name                = each.key
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name      = each.value.ipconfig_name
    subnet_id = azurerm_subnet.subnets[each.value.subnet_key].id
    private_ip_address_allocation = "Dynamic"

    public_ip_address_id = (
      each.value.public_ip_required 
      ? azurerm_public_ip.public_ip[each.value.public_ip_key].id 
      : null
    )
  }
}

# NSG - NIC 연결
resource "azurerm_network_interface_security_group_association" "bastion_nsg" {
  network_interface_id      = azurerm_network_interface.nic["bastion-nic"].id
  network_security_group_id = azurerm_network_security_group.nsg["nsg-bastion"].id
}

resource "azurerm_network_interface_security_group_association" "web1_nsg" {
  network_interface_id      = azurerm_network_interface.nic["web1-nic"].id
  network_security_group_id = azurerm_network_security_group.nsg["nsg-web1"].id
}

resource "azurerm_network_interface_security_group_association" "web2_nsg" {
  network_interface_id      = azurerm_network_interface.nic["web2-nic"].id
  network_security_group_id = azurerm_network_security_group.nsg["nsg-web2"].id
}

resource "azurerm_network_interface_security_group_association" "db1_nsg" {
  network_interface_id      = azurerm_network_interface.nic["db1-nic"].id
  network_security_group_id = azurerm_network_security_group.nsg["nsg-db1"].id
}

resource "azurerm_network_interface_security_group_association" "db2_nsg" {
  network_interface_id      = azurerm_network_interface.nic["db2-nic"].id
  network_security_group_id = azurerm_network_security_group.nsg["nsg-db2"].id
}

# Public IP
resource "azurerm_public_ip" "public_ip" {
  for_each            = var.public_ips
  name                = each.key
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = each.value.allocation_method
  sku                 = each.value.sku
}

# NAT Gateway
resource "azurerm_nat_gateway" "nat_gateway" {
  name                = "natgw-cus"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Standard"
}

# NAT Gateway - Public IP 연결
resource "azurerm_nat_gateway_public_ip_association" "natgw_pip" {
  nat_gateway_id       = azurerm_nat_gateway.nat_gateway.id
  public_ip_address_id = azurerm_public_ip.public_ip["natgw-ip"].id
}

# NAT Gateway - Subnet 연결
resource "azurerm_subnet_nat_gateway_association" "natgw_subnet" {
  for_each = { for key, value in var.subnets : key => value if value.outbound == false }
  subnet_id      = azurerm_subnet.subnets[each.key].id
  nat_gateway_id = azurerm_nat_gateway.nat_gateway.id
}