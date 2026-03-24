#================================================
#Configuracion máquina Ubuntu server web frontend
#================================================
#IP publica
#resource "azurerm_public_ip" "ub1-ip-PRE" {
#  name                = "ub1-ip-PRE"
#  resource_group_name = local.rg_name
#  location            = local.location
#  allocation_method   = "Static"
#  tags = {
#    environment = "PRE"
#  }
#}

#output "ub1-ip-PRE" {
#  value = azurerm_public_ip.ub1-ip-PRE.ip_address #A la hora de desplegar nos da la IP de la maquina de Alma Linux
#}

#network interface ubuntu server pre
#resource "azurerm_network_interface" "ub1-interface-PRE" {
 # name                = "ub1-interface-PRE"
  #location            = local.location
  #resource_group_name = local.rg_name

  #ip_configuration {
   # name                          = "internal"
    #subnet_id                     = azurerm_subnet.subnet01-PRE.id
    #private_ip_address_allocation = "Static"
    #private_ip_address = "10.0.1.100"
    #public_ip_address_id = azurerm_public_ip.ub1-ip-PRE.id
  #}
  #tags = {
   # environment = "PRE"
  #}
#}


#resource "azurerm_virtual_machine" "UB1-LegDig-PRE" {
 # name                  = "UB1-LegDig-PRE"
 # location              = local.location
 # resource_group_name   = local.rg_name
 # network_interface_ids = [azurerm_network_interface.ub1-interface-PRE.id]
 # vm_size               = "Standard_B2as_v2"

 # storage_image_reference {
 #   publisher = "canonical"
#    offer     = "ubuntu-24_04-lts"
#    sku       = "ubuntu-pro-gen1"
 #   version   = "latest"
 # }

 # storage_os_disk {
 #   name              = "UB1-PRE"
 #   caching           = "ReadWrite"
 #   create_option     = "FromImage"
 #   managed_disk_type = "Standard_LRS"
 #   disk_size_gb      = 100
 # }

 # os_profile {
  #  computer_name  = "UB1-PRE"
    #admin_username = "webmaster-PRE"
   # admin_password = "3ste0rdEnAdOresS3gRo"
  #}
 # os_profile_linux_config {
  #  disable_password_authentication = false
 # }
 # tags = {
  #  environment = "PRE"
 # }
#}
