resource "azurerm_lb" "business-tier-lb" {
  name                = "business-tier-lb"
  location            = azurerm_resource_group.corporate-production-rg.location
  resource_group_name = azurerm_resource_group.corporate-production-rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "businesslbfrontendip"
    public_ip_address_id          = azurerm_public_ip.corporate-prod-ip.id
  }
}

resource "azurerm_lb_rule" "production-inbound-rules" {
  loadbalancer_id                = azurerm_lb.business-tier-lb.id
  resource_group_name            = azurerm_resource_group.corporate-production-rg.name
  name                           = "http-inbound-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "businesslbfrontendip"
  probe_id                       = azurerm_lb_probe.http-inbound-probe.id
  backend_address_pool_ids        = ["${azurerm_lb_backend_address_pool.business-backend-pool.id}"]
 

}

resource "azurerm_lb_probe" "http-inbound-probe" {
  resource_group_name = azurerm_resource_group.corporate-production-rg.name
  loadbalancer_id     = azurerm_lb.business-tier-lb.id
  name                = "http-inbound-probe"
  port                = 80
}

resource "azurerm_lb_backend_address_pool" "business-backend-pool" {
  loadbalancer_id = azurerm_lb.business-tier-lb.id
  name            = "business-backend-pool"
}

resource "azurerm_network_interface_backend_address_pool_association" "business-tier-pool" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.corpnic.*.id[count.index]
  ip_configuration_name   = azurerm_network_interface.corpnic.*.ip_configuration.0.name[count.index]
  backend_address_pool_id = azurerm_lb_backend_address_pool.business-backend-pool.id

}

