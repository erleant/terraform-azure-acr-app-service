resource "azurerm_network_security_group" "corporate-production-nsg" {
  name                = "${var.corp}-nsg"
  location            = azurerm_resource_group.corporate-production-rg.location
  resource_group_name = azurerm_resource_group.corporate-production-rg.name

  security_rule {
    name                       = "HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 80
    source_address_prefix      = "$MY_IP"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "SSH"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 22
    source_address_prefix      = "$MY_IP"
    destination_address_prefix = "*"
  }
}

resource "azurerm_availability_set" "vmavset" {
  name                         = "vmavset"
  location                     = azurerm_resource_group.corporate-production-rg.location
  resource_group_name          = azurerm_resource_group.corporate-production-rg.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
  tags = {
    environment = "Production"
  }
}

locals {
  custom_data = <<CUSTOM_DATA
#!/bin/bash
sudo -i 
apt-get install nginx -y
apt-get install git -y

git clone https://github.com/lerna/website.git /home/$user/webapp 

cp -a /home/$user/webapp/. /var/www/html/
sed "s/Documentation | Lerna/`hostname`/" /var/www/html/index.html  > /var/www/index.html 
rm /var/www//html/index.html 
cp /var/www/index.html /var/www/html/index.html 
rm /var/www/html/index.nginx-debian.html

systemctl enable nginx
systemctl start nginx

CUSTOM_DATA
}

resource "azurerm_linux_virtual_machine" "corporate-business-linux-vm" {

  name                  = "${var.corp}linuxvm${count.index +1}"
  location              = azurerm_resource_group.corporate-production-rg.location
  resource_group_name   = azurerm_resource_group.corporate-production-rg.name
  availability_set_id   = azurerm_availability_set.vmavset.id
  network_interface_ids = ["${element(azurerm_network_interface.corpnic.*.id, count.index)}"]
  size                  = "Standard_B1s"
  count                 = 2

  os_disk {
    name                 = "${var.corp}disk${count.index +1}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"                    
    offer     = "0001-com-ubuntu-server-focal" 
    sku       = "20_04-lts-gen2"               
    version   = "latest"
  }

  computer_name                   = "vm-linux-${count.index +1}"
  admin_username                  = "$user"
  admin_password                  = "$p"
  disable_password_authentication = false
  custom_data                     = base64encode(local.custom_data)

}
