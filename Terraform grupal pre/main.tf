#Hacemos una llamada 
data "azurerm_resource_group" "rg_fct_ohmygit" {
  name = "RG_OhMyGit"
}


# Storage Account para el backend
resource "azurerm_storage_account" "terratf" {
  name                     = "terratfsa12345"
  resource_group_name      = local.rg_name
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Contenedor para guardar el state
resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.terratf.id
}


#Creamos la virtual network de PRO
resource "azurerm_virtual_network" "virtual-network-PRE" {
  name                = "virtual-network-PRE" #llama al apartado nombre de virtual_network en los locals
  location            = local.location
  resource_group_name = local.rg_name
  address_space       = ["10.0.0.0/16"] #llama al apartado prefijos de red de virtual_network en los locals
  tags = {
    environment = "PRE"
  }
}

#Subred1
resource "azurerm_subnet" "subnet01-PRE" {
  name                 = "subnet01-PRE"
  resource_group_name  = local.rg_name
  virtual_network_name = azurerm_virtual_network.virtual-network-PRE.name
  address_prefixes     = ["10.0.1.0/24"]
}

#IP publica que le asignaremos a la máqiona, esta es la ip a la que nos conectaremos
resource "azurerm_public_ip" "alma-ip-PRE" {
  name                = "alma-ip-PRE"
  resource_group_name = local.rg_name
  location            = local.location
  allocation_method   = "Static"
  tags = {
    environment = "PRE"
  }
}

#Virtual interface para la primera máquina
resource "azurerm_network_interface" "alma-interface-PRE" {
  name                = "alma-interface-PRE"
  location            = local.location
  resource_group_name = local.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet01-PRE.id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.0.1.12"
    public_ip_address_id = azurerm_public_ip.alma-ip-PRE.id
  }
  tags = {
    environment = "PRE"
  }
}

#NSG, establecido por error al no declararlo
resource "azurerm_network_security_group" "LegDig-nsg-PRE" {
  name                = "LegDig-nsg-PRE"
  location            = local.location
  resource_group_name = local.rg_name

  # SSH
  security_rule {
    name                       = "allow_ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # HTTP (80)
  security_rule {
    name                       = "allow_http"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # HTTPS (443)
  security_rule {
    name                       = "allow_https"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # WEB personal (8080)
  security_rule {
    name                       = "allow_8080"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = {
    environment = "PRE"
  }
}

#Asociacion de nuestro security group a las subredes, establecido por error al no declararlo
resource "azurerm_subnet_network_security_group_association" "LegDig-nsgass" {
  subnet_id                 = azurerm_subnet.subnet01-PRE.id
  network_security_group_id = azurerm_network_security_group.LegDig-nsg-PRE.id
}

#Creación máquina virtual
resource "azurerm_virtual_machine" "Juana-de-Arco" {
  name                  = "Juana-de-Arco"
  location              = local.location
  resource_group_name   = local.rg_name
  network_interface_ids = [azurerm_network_interface.alma-interface-PRE.id]
  vm_size               = "Standard_B2as_v2"

  storage_image_reference {
    publisher = "almalinux"
    offer     = "almalinux-x86_64"
    sku       = "9-gen2"
    version   = "latest"
  }

  storage_os_disk {
    name              = "Juana-de-Arco-dsk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = 60
  }

  os_profile {
    computer_name  = "Juana-de-Arco-PRE"
    admin_username = "admcent-PRE"
    admin_password = "L@c0ntr4s3n4de3steban"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "PRE"
  }
}

# #================================================
# #Configuracion máquina Ubuntu server web frontend
# #================================================
# #IP publica
# resource "azurerm_public_ip" "Clara-Campoamor-ip" {
#   name                = "Clara-Campoamor-ip"
#   resource_group_name = local.rg_name
#   location            = local.location
#   allocation_method   = "Static"
#   tags = {
#     environment = "PRE"
#   }
# }

# #network interface ubuntu server pre
# resource "azurerm_network_interface" "Clara-Campoamor-interface" {
#   name                = "Clara-Campoamor-interface"
#   location            = local.location
#   resource_group_name = local.rg_name

#     ip_configuration {
#         name = "internal"
#         subnet_id = azurerm_subnet.subnet01-PRE.id
#         private_ip_address_allocation = "Static"
#         private_ip_address = "10.0.1.100"
#         public_ip_address_id = azurerm_public_ip.Clara-Campoamor-ip.id
#   }
# tags = {
#     environment = "PRE"
#   }
# }


# resource "azurerm_virtual_machine" "Clara-Campoamor" {
#   name                  = "Clara-Campoamor"
#   location              = local.location
#   resource_group_name   = local.rg_name
#   network_interface_ids = [azurerm_network_interface.Clara-Campoamor-interface.id]
#   vm_size               = "Standard_B2as_v2"

# storage_image_reference {
#    publisher = "canonical"
#     offer     = "ubuntu-24_04-lts"
#     sku       = "ubuntu-pro-gen1"
#    version   = "latest"
#   }

#   storage_os_disk {
#     name              = "Clara-Campoamor-dsk"
#     caching           = "ReadWrite"
#     create_option     = "FromImage"
#     managed_disk_type = "Standard_LRS"
#     disk_size_gb      = 100
#   }

# os_profile {
#     computer_name  = "Clara-Campoamor-PRE"
#     admin_username = "webmaster-PRE"
#     admin_password = "3ste0rdEnAdOresS3gRo"
#   }
#   os_profile_linux_config {
#     disable_password_authentication = false
#   }
#   tags = {
#     environment = "PRE"
#   }
# }

# #==============================================
# #Creamos un servidor Ubuntu para la BBDD de PRE
# #==============================================
# resource "azurerm_public_ip" "Mary-Ritter-Beard-ip" {
#   name                = "Mary-Ritter-Beard-ip"
#   resource_group_name = local.rg_name
#   location            = local.location
#   allocation_method   = "Static"
#   tags = {
#     environment = "PRE"
#   }
# }

# #network interface ubuntu server pro
# resource "azurerm_network_interface" "Mary-Ritter-Beard-interface" {
#   name                = "Mary-Ritter-Beard-interface"
#   location            = local.location
#   resource_group_name = local.rg_name

#     ip_configuration {
#         name = "internal"
#         subnet_id = azurerm_subnet.subnet01-PRE.id
#         private_ip_address_allocation = "Static"
#         private_ip_address = "10.0.1.33"
#         public_ip_address_id = azurerm_public_ip.Mary-Ritter-Beard-ip.id
#   }
# tags = {
#     environment = "PRE"
#   }
# }

# #Despliegue de la máquina virtual de Ubuntu
# resource "azurerm_virtual_machine" "Mary-Ritter-Beard" {
#   name                  = "Mary-Ritter-Beard"
#   location              = local.location
#   resource_group_name   = local.rg_name
#   network_interface_ids = [azurerm_network_interface.Mary-Ritter-Beard-interface.id]
#   vm_size               = "Standard_B2as_v2"

# storage_image_reference {
#    publisher = "canonical"
#     offer     = "ubuntu-24_04-lts"
#     sku       = "ubuntu-pro-gen1"
#    version   = "latest"
#   }

#   storage_os_disk {
#     name              = "Mary-Ritter-Beard-dsk"
#     caching           = "ReadWrite"
#     create_option     = "FromImage"
#     managed_disk_type = "Standard_LRS"
#     disk_size_gb      = 100
#   }

# os_profile {
#     computer_name  = "Mary-Ritter-Beard-PRE"
#     admin_username = "BBDDadmin-PRE"
#     admin_password = "C0nt1en3l4s8BDD"
#   }
#   os_profile_linux_config {
#     disable_password_authentication = false
#   }
#   tags = {
#     environment = "PRE"
#   }
# }