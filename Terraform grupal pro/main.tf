#Hacemos una llamada 
data "azurerm_resource_group" "rg_fct_ohmygit" {
  name = "RG_OhMyGit"
}

#Creamos la virtual network de PRO
resource "azurerm_virtual_network" "virtual-network-PRO" {
  name                = "virtual-network-PRO" #llama al apartado nombre de virtual_network en los locals
  location            = local.location
  resource_group_name = local.rg_name
  address_space       = ["10.0.0.0/16"] #llama al apartado prefijos de red de virtual_network en los locals
  tags = {
    environment = "PRO"
  }
}

#Subred1
resource "azurerm_subnet" "subnet01-PRO" {
  name                 = "subnet01-PRO"
  resource_group_name  = local.rg_name
  virtual_network_name = azurerm_virtual_network.virtual-network-PRO.name
  address_prefixes     = ["10.0.2.0/24"]
}

#IP publica que le asignaremos a la máqiona, esta es la ip a la que nos conectaremos
resource "azurerm_public_ip" "alma-ip-PRO" {
  name                = "alma-ip-PRO"
  resource_group_name = local.rg_name
  location            = local.location
  allocation_method   = "Static"
  tags = {
    environment = "PRO"
  }
}

output "websubnet01_id" {
  value = azurerm_public_ip.alma-ip-PRO.ip_address #A la hora de desplegar nos da la IP de la maquina de Alma Linux
}

#Virtual interface para la primera máquina
resource "azurerm_network_interface" "alma-interface-PRO" {
  name                = "alma-interface-PRO"
  location            = local.location
  resource_group_name = local.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet01-PRO.id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.0.2.50"
    public_ip_address_id = azurerm_public_ip.alma-ip-PRO.id
  }
  tags = {
    environment = "PRO"
  }
}

#NSG, establecido por error al no declararlo
resource "azurerm_network_security_group" "LegDig-nsg-PRO" {
  name                = "LegDig-nsg-PRO"
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
    environment = "PRO"
  }
}

#Asociacion de nuestro security group a las subredes, establecido por error al no declararlo
resource "azurerm_subnet_network_security_group_association" "LegDig-nsgass" {
  subnet_id                 = azurerm_subnet.subnet01-PRO.id
  network_security_group_id = azurerm_network_security_group.LegDig-nsg-PRO.id
}

#Creación máquina virtual
resource "azurerm_virtual_machine" "Isabel-La-Catolica" {
  name                  = "Isabel-La-Catolica" #usamos el valor definido en terraform.tfvars
  location              = local.location
  resource_group_name   = local.rg_name
  network_interface_ids = [azurerm_network_interface.alma-interface-PRO.id]
  vm_size               = "Standard_B2as_v2"

  storage_image_reference {
    publisher = "almalinux"
    offer     = "almalinux-x86_64"
    sku       = "9-gen2"
    version   = "latest"
  }

  storage_os_disk {
    name              = "Isabel-La-Catolica-dsk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = 60
  }

  os_profile {
    computer_name  = "Isabel-La-Catolica"
    admin_username = "admcent-PRO"
    admin_password = "L@c0ntr4s3n4de3steban-PRO"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "PRO"
  }
}
