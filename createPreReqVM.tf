
# Definition of prerequisite mandatory for Packer to deploy a VM 
# - VNet Azure / Azure VNet
# - Network Security Group (apply to Subnet)
# - SubNet
# - a Public IP
# - a NIC associated to Subnet and Public IP
#
# More infos
# https://github.com/Azure/packer-azure/issues/201 
#

# Variable to define Azure Location where to deploy
# To list available Azure Location using CLI : 
# az account list-locations
variable "AzureRegion" {
    description = "Region Azure to choose for deployment"
    type = "string"
    default = "North Europe"
}

# Resource Group Definition

resource "azurerm_resource_group" "TestSL-TF001" {
    name = "testSL-TF001"
    location = "${var.AzureRegion}"
    tags {
        environment = "test"
        project = "terraformAutoTraining"
        domain = "IOS-IPO"
    }  
}

#Groups already existing for us
resource "azurerm_resource_group" "TF-Network" {
    name = "Network"
    location = "${var.AzureRegion}"
    tags {
        environment = "test"
        domain = "IOS"
    }  
}


# Définition d un VNet
# plus d info : https://www.terraform.io/docs/providers/azurerm/r/virtual_network.html
resource "azurerm_virtual_network" "TF-Vnet-Test_Lan" {
  name                = "Test_Lan"
  resource_group_name = "${azurerm_resource_group.TF-Network.name}"
  address_space       = ["10.152.0.0/16"]
  location            = "${var.AzureRegion}"
 # dns_servers         = ["8.8.8.8", "10.0.0.5"]
}


# Network Security Group Definition : you can customize here depending on your type of VM
# More info : https://www.terraform.io/docs/providers/azurerm/r/network_security_group.html
resource "azurerm_network_security_group" "TF-NSG-Test001" {
  name                = "NSG-Test001"
  location            = "${var.AzureRegion}"
  resource_group_name = "${azurerm_resource_group.testSL-TF001.name}"
  # regle  autorisant SSH
  security_rule {
    name                       = "OK-SSH-entrant"
    priority                   = 1200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  # regle  autorisant HTTP 
  #security_rule {
  #  name                       = "OK-HTTP-entrant"
  #  priority                   = 1300
  #  direction                  = "Inbound"
  #  access                     = "Allow"
  #  protocol                   = "Tcp"
  #  source_port_range          = "*"
  #  destination_port_range     = "80"
  #  source_address_prefix      = "*"
  #  destination_address_prefix = "*"
  #}

  # regle  autorisant RDP (TCP 3389) 
  security_rule {
    name                       = "OK-RDP-entrant"
    priority                   = 1400
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# SubNet Definition
# More info : https://www.terraform.io/docs/providers/azurerm/r/subnet.html 
resource "azurerm_subnet" "TF-Subnet-Test001" {
  name                      = "Subnet-Test001"
  resource_group_name       = "${azurerm_resource_group.testSL-TF001.name}"
  virtual_network_name      = "${azurerm_virtual_network.TF-Vnet-Test_Lan.name}"
  address_prefix            = "10.152.120.0/24"
  network_security_group_id = "${azurerm_network_security_group.TF-NSG-Test001.id}"
}

# Definition of Public IP 
# more info : https://www.terraform.io/docs/providers/azurerm/r/public_ip.html
resource "azurerm_public_ip" "TF-PublicIp-VM01" {
  name                         = "PublicIp-VM01"
  location                     = "${var.AzureRegion}"
  resource_group_name          = "${azurerm_resource_group.testSL-TF001.name}"
  public_ip_address_allocation = "static"
  domain_name_label            = "publicVM01"
}

# Network Card Interface definition for VM01
# More info : https://www.terraform.io/docs/providers/azurerm/r/network_interface.html
resource "azurerm_network_interface" "TF-NIC1-VM01" {
  name                = "NIC1-VM01"
  location            = "${var.AzureRegion}"
  resource_group_name = "${azurerm_resource_group.testSL-TF001.name}"

  ip_configuration {
    name                          = "configIPNIC1-VM01"
    subnet_id                     = "${azurerm_subnet.TF-Subnet-Test001.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id = "${azurerm_public_ip.TF-PublicIp-VM01.id}"
    }
}

# --------------------
# - Output
# --------------------

output "IP Publique de la VM" {
  value = "${azurerm_public_ip.TF-PublicIp-VM01.ip_address}"
}

output "FQDN de la VM" {
  value = "${azurerm_public_ip.TF-PublicIp-VM01.fqdn}"
}

output "NICid de la VM" {
  value = "${azurerm_network_interface.TF-NIC1-VM01.id}"
}