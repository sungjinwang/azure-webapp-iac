resource "azurerm_lb" "lb" {
  name                = "lb-cus"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  frontend_ip_configuration {       
    name                 = "lb-cus-front-ipconfig"
    public_ip_address_id = azurerm_public_ip.public_ip["lb-ip"].id  
  }
}

# Backend pool
resource "azurerm_lb_backend_address_pool" "backend_pool" {
  name                = "lb-cus-back-ipconfig"
  loadbalancer_id     = azurerm_lb.lb.id
}

# Health probe
resource "azurerm_lb_probe" "probe" {
  name                = "hb-80"
  loadbalancer_id     = azurerm_lb.lb.id
  protocol            = "Tcp"
  port                = 80
  # request_path        = "/"
  interval_in_seconds = 5
}

# LB rule
resource "azurerm_lb_rule" "lb_rule" {
  name                           = "lb-cus-rule"
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.lb.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [ azurerm_lb_backend_address_pool.backend_pool.id ]
  probe_id                       = azurerm_lb_probe.probe.id
}

# Backend pool에 NIC 연결 (VM 배치)
resource "azurerm_network_interface_backend_address_pool_association" "backend_web1" {
  network_interface_id    = azurerm_network_interface.nic["web1-nic"].id
  ip_configuration_name   = "web1-ipconfig"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_pool.id
}

resource "azurerm_network_interface_backend_address_pool_association" "backend_web2" {
  network_interface_id    = azurerm_network_interface.nic["web2-nic"].id
  ip_configuration_name   = "web2-ipconfig"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_pool.id
}
