resource "azurerm_resource_group" "corporate-production-rg" {
  name     = "rg${var.corp}"
  location = "westeurope"
}

resource "azurerm_virtual_network" "corporate-prod-vnet" {
  name                = "${var.corp}-vnet"
  location            = azurerm_resource_group.corporate-production-rg.location
  resource_group_name = azurerm_resource_group.corporate-production-rg.name
  address_space       = ["10.20.0.0/16"]

  tags = {
    environment = "Production Network"
  }
}

resource "azurerm_subnet" "business-tier-subnet" {
  name                 = "${var.corp}-subnet"
  resource_group_name  = azurerm_resource_group.corporate-production-rg.name
  virtual_network_name = azurerm_virtual_network.corporate-prod-vnet.name
  address_prefixes     = ["10.20.10.0/24"]
}

 resource "azurerm_public_ip" "corporate-prod-ip" {
  name                = "PublicIPForLB"
  location            = azurerm_resource_group.corporate-production-rg.location
  resource_group_name = azurerm_resource_group.corporate-production-rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# resource "azurerm_public_ip" "vm2" {
#   count                        = 2
#   name                         = "pipTerraformVM${count.index}"
#   # name                         = "pipTerraformVM2"
#   location                     = azurerm_resource_group.corporate-production-rg.location
#   resource_group_name          = azurerm_resource_group.corporate-production-rg.name
#   allocation_method            = "Static"
#   sku                          = "Standard" 
# }

resource "azurerm_network_interface" "corpnic" {
  name                = "${var.corp}-nic-${count.index +1}"
  location            = azurerm_resource_group.corporate-production-rg.location
  resource_group_name = azurerm_resource_group.corporate-production-rg.name
  count               = 2

  ip_configuration {
    name                          = "ipconfig-${count.index +1}"
    subnet_id                     = azurerm_subnet.business-tier-subnet.id
    private_ip_address_allocation = "Dynamic"
    # public_ip_address_id          = azurerm_public_ip.vm2.*.id[ceil((count.index))]
  }
}


resource "azurerm_subnet_network_security_group_association" "corporate-production-nsg-assoc" {
  subnet_id                 = azurerm_subnet.business-tier-subnet.id
  network_security_group_id = azurerm_network_security_group.corporate-production-nsg.id
}
resource "azurerm_network_interface_security_group_association" "example" {
  count                     = 2
  network_interface_id      = azurerm_network_interface.corpnic.*.id[count.index]
  network_security_group_id = azurerm_network_security_group.corporate-production-nsg.id
}