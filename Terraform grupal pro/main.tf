# Storage Account para el backend
resource "azurerm_storage_account" "terratf" {
  name                     = "terratfsa12345pro"
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
resource "azurerm_virtual_network" "Marie-Curie-PRO" {
  name                = "Marie-Curie-PRO" #llama al apartado nombre de virtual_network en los locals
  location            = local.location
  resource_group_name = local.rg_name
  address_space       = ["10.0.0.0/16"] #llama al apartado prefijos de red de virtual_network en los locals
  tags = {
    environment = "PRO"
  }
}

#Subred1
resource "azurerm_subnet" "Malala-Yousafzai-PRO" {
  name                 = "Malala-Yousafzai-PRO"
  resource_group_name  = local.rg_name
  virtual_network_name = azurerm_virtual_network.Marie-Curie-PRO.name
  address_prefixes     = ["10.0.2.0/24"]
}

#IP publica que le asignaremos a la máqiona, esta es la ip a la que nos conectaremos
resource "azurerm_public_ip" "Isabel-La-Catolica-PRO" {
  name                = "Isabel-La-Catolica-PRO"
  resource_group_name = local.rg_name
  location            = local.location
  allocation_method   = "Static"
  tags = {
    environment = "PRO"
  }
}

#Virtual interface para la primera máquina
resource "azurerm_network_interface" "Isabel-La-Catolica-PRO" {
  name                = "Isabel-La-Catolica-PRO"
  location            = local.location
  resource_group_name = local.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Malala-Yousafzai-PRO.id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.0.2.12"
    public_ip_address_id = azurerm_public_ip.Isabel-La-Catolica-PRO.id
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
  subnet_id                 = azurerm_subnet.Malala-Yousafzai-PRO.id
  network_security_group_id = azurerm_network_security_group.LegDig-nsg-PRO.id
}

#Creación máquina virtual
resource "azurerm_virtual_machine" "Isabel-La-Catolica" {
  name                  = "Isabel-La-Catolica" #usamos el valor definido en terraform.tfvars
  location              = local.location
  resource_group_name   = local.rg_name
  network_interface_ids = [azurerm_network_interface.Isabel-La-Catolica-PRO.id]
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

#================================================
#Configuracion máquina1 Ubuntu server web frontend
#================================================
#IP publica
resource "azurerm_public_ip" "Santa-Catalina-de-Siena-ip" {
  name                = "Santa-Catalina-de-Siena-ip"
  resource_group_name = local.rg_name
  location            = local.location
  allocation_method   = "Static"
  tags = {
    environment = "PRO"
  }
}

#network interface ubuntu server pro
resource "azurerm_network_interface" "Santa-Catalina-de-Siena-interface" {
  name                = "Santa-Catalina-de-Siena-interface"
  location            = local.location
  resource_group_name = local.rg_name

    ip_configuration {
        name = "internal"
        subnet_id = azurerm_subnet.Malala-Yousafzai-PRO.id
        private_ip_address_allocation = "Static"
        private_ip_address = "10.0.2.75"
        public_ip_address_id = azurerm_public_ip.Santa-Catalina-de-Siena-ip.id
  }
tags = {
    environment = "PRO"
  }
}

#Despliegue de la máquina virtual de Ubuntu
resource "azurerm_virtual_machine" "Santa-Catalina-de-Siena" {
  name                  = "Santa-Catalina-de-Siena"
  location              = local.location
  resource_group_name   = local.rg_name
  network_interface_ids = [azurerm_network_interface.Santa-Catalina-de-Siena-interface.id]
  vm_size               = "Standard_B2as_v2"

storage_image_reference {
   publisher = "canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "ubuntu-pro-gen1"
   version   = "latest"
  }

  storage_os_disk {
    name              = "Santa-Catalina-de-Siena-dsk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = 100
  }

os_profile {
    computer_name  = "Santa-Catalina-de-Siena-PRO"
    admin_username = "webmaster1-PRO"
    admin_password = "3ste0rdEnAdOresS3gRo-PRO"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "PRO"
  }
}

#================================================
#Configuracion máquina1 Ubuntu server web frontend
#================================================
#IP publica
resource "azurerm_public_ip" "Santa-Teresa-de-Jesus-ip" {
  name                = "Santa-Teresa-de-Jesus-ip"
  resource_group_name = local.rg_name
  location            = local.location
  allocation_method   = "Static"
  tags = {
    environment = "PRO"
  }
}

#network interface ubuntu server pro
resource "azurerm_network_interface" "Santa-Teresa-de-Jesus-interface" {
  name                = "Santa-Teresa-de-Jesus-interface"
  location            = local.location
  resource_group_name = local.rg_name

    ip_configuration {
        name = "internal"
        subnet_id = azurerm_subnet.Malala-Yousafzai-PRO.id
        private_ip_address_allocation = "Static"
        private_ip_address = "10.0.2.100"
        public_ip_address_id = azurerm_public_ip.Santa-Teresa-de-Jesus-ip.id
  }
tags = {
    environment = "PRO"
  }
}

#Despliegue de la máquina virtual de Ubuntu
resource "azurerm_virtual_machine" "Santa-Teresa-de-Jesus" {
  name                  = "Santa-Teresa-de-Jesus"
  location              = local.location
  resource_group_name   = local.rg_name
  network_interface_ids = [azurerm_network_interface.Santa-Teresa-de-Jesus-interface.id]
  vm_size               = "Standard_B2as_v2"

storage_image_reference {
   publisher = "canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "ubuntu-pro-gen1"
   version   = "latest"
  }

  storage_os_disk {
    name              = "Santa-Teresa-de-Jesus-dsk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = 100
  }

os_profile {
    computer_name  = "Santa-Teresa-de-Jesus-PRO"
    admin_username = "webmaster2-PRO"
    admin_password = "3ste0rdEnAdOresS3gRo-PRO"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "PRO"
  }
}

#==============================================
#Creamos un servidor Ubuntu para la BBDD de PRO
#==============================================
resource "azurerm_public_ip" "Margaret-Cross-Norton-ip" {
  name                = "Margaret-Cross-Norton-ip"
  resource_group_name = local.rg_name
  location            = local.location
  allocation_method   = "Static"
  tags = {
    environment = "PRO"
  }
}

#network interface ubuntu server pro
resource "azurerm_network_interface" "Margaret-Cross-Norton-interface" {
  name                = "Margaret-Cross-Norton-interface"
  location            = local.location
  resource_group_name = local.rg_name

    ip_configuration {
        name = "internal"
        subnet_id = azurerm_subnet.Malala-Yousafzai-PRO.id
        private_ip_address_allocation = "Static"
        private_ip_address = "10.0.2.33"
        public_ip_address_id = azurerm_public_ip.Margaret-Cross-Norton-ip.id
  }
tags = {
    environment = "PRO"
  }
}

#Despliegue de la máquina virtual de Ubuntu
resource "azurerm_virtual_machine" "Margaret-Cross-Norton" {
  name                  = "Margaret-Cross-Norton"
  location              = local.location
  resource_group_name   = local.rg_name
  network_interface_ids = [azurerm_network_interface.Margaret-Cross-Norton-interface.id]
  vm_size               = "Standard_B2as_v2"

storage_image_reference {
   publisher = "canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "ubuntu-pro-gen1"
   version   = "latest"
  }

  storage_os_disk {
    name              = "Margaret-Cross-Norton-dsk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = 100
  }

os_profile {
    computer_name  = "Margaret-Cross-Norton-PRO"
    admin_username = "BBDDadmin-PRO"
    admin_password = "C0nt1en3l4s8BDD-PRO"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "PRO"
  }
}

#====================================================
#Máquina para AKS
#====================================================
#Creamos una IP pública para la máquina de maria-magdalena
resource "azurerm_public_ip" "maria_magdalena_ip_PRO" {
  name                = "maria-magdalena-ip-PRO"
  resource_group_name = local.rg_name
  location            = local.location
  allocation_method   = "Static"
  tags = {
    environment = "PRO"
  }
}

#Network interface de Maria Magdalena
resource "azurerm_network_interface" "maria_magdalena-nic-PRO" {
  name                = "maria-magdalena-nic-PRO"
  location            = local.location
  resource_group_name = local.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.maria-magdalena-PRO.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.5"
    public_ip_address_id          = azurerm_public_ip.maria_magdalena_ip_PRO.id
  }
}

#Maquina maria magdalena - Ubuntu con AKS
resource "azurerm_linux_virtual_machine" "maria-magdalena-pro" {
  name                = "maria-magdalena-pro"
  location            = local.location
  resource_group_name = local.rg_name
  size                = "Standard_B2s"
  admin_username = "adminubuntu"
  admin_password = "L0skU8ern3tes"
  disable_password_authentication = false
  network_interface_ids = [azurerm_network_interface.maria_magdalena-nic-PRO.id]

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 40
  }

  tags = {
    environment = "PRO"
  }
}

#AKS con 3 clústeres para cada aplicación de observabilidad
locals {
  aks_clusters = {
    aks-pro1 = {
      name       = "maria-emilia-aks"
      dns_prefix = "aks-dns1-pro"
    }
    aks-pro2 = {
      name       = "maria-eugenia-aks"
      dns_prefix = "aks-dns2-pro"
    }
    aks-pro3 = {
      name       = "maria-rousse-aks"
      dns_prefix = "aks-dns3-pro"
    }
  }
}

resource "azurerm_kubernetes_cluster" "aks" {
  for_each            = local.aks_clusters
  name                = each.value.name
  location            = local.location
  resource_group_name = local.rg_name
  dns_prefix          = each.value.dns_prefix

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_DS2_v2"
    os_sku     = "Ubuntu"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "PRO"
  }
}

# ===========================================================
# PUBLIC LOAD BALANCER MARY-W-JACKSON (PRO)
# ===========================================================

# IP pública del Load Balancer
resource "azurerm_public_ip" "Mary-W-Jackson-ip-PRO" {
  name                = "Mary-W-Jackson-ip-PRO"
  location            = local.location
  resource_group_name = local.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = "PRO"
  }
}

# Load Balancer principal
resource "azurerm_lb" "Mary-W-Jackson-lb-PRO" {
  name                = "Mary-W-Jackson-lb-PRO"
  location            = local.location
  resource_group_name = local.rg_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "Mary-W-Jackson-frontend-PRO"
    public_ip_address_id = azurerm_public_ip.Mary-W-Jackson-ip-PRO.id
  }

  tags = {
    environment = "PRO"
  }
}

# Backend pool
resource "azurerm_lb_backend_address_pool" "Mary-W-Jackson-backend-PRO" {
  name            = "Mary-W-Jackson-backend-PRO"
  loadbalancer_id = azurerm_lb.Mary-W-Jackson-lb-PRO.id
}

# Asociación NIC → Backend pool (APP1)
resource "azurerm_network_interface_backend_address_pool_association" "Mary-W-Jackson-app1" {
  network_interface_id    = azurerm_network_interface.Santa-Catalina-de-Siena-interface.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.Mary-W-Jackson-backend-PRO.id
}

# Asociación NIC → Backend pool (APP2)
resource "azurerm_network_interface_backend_address_pool_association" "Mary-W-Jackson-app2" {
  network_interface_id    = azurerm_network_interface.Santa-Teresa-de-Jesus-interface.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.Mary-W-Jackson-backend-PRO.id
}

# Health Probe (80/TCP)
resource "azurerm_lb_probe" "Mary-W-Jackson-probe-PRO" {
  name            = "Mary-W-Jackson-probe-PRO"
  loadbalancer_id = azurerm_lb.Mary-W-Jackson-lb-PRO.id
  protocol        = "Tcp"
  port            = 80
}

# Regla de balanceo (puerto 80)
resource "azurerm_lb_rule" "Mary-W-Jackson-rule-80-PRO" {
  name                            = "Mary-W-Jackson-rule-80-PRO"
  loadbalancer_id                 = azurerm_lb.Mary-W-Jackson-lb-PRO.id
  protocol                        = "Tcp"
  frontend_port                   = 80
  backend_port                    = 80
  frontend_ip_configuration_name  = "Mary-W-Jackson-frontend-PRO"
  probe_id                        = azurerm_lb_probe.Mary-W-Jackson-probe-PRO.id
}


# Outbound rule (necesaria en LB Standard)
resource "azurerm_lb_outbound_rule" "Mary-W-Jackson-outbound-PRO" {
  name                    = "Mary-W-Jackson-outbound-PRO"
  loadbalancer_id         = azurerm_lb.Mary-W-Jackson-lb-PRO.id
  protocol                = "All"
  backend_address_pool_id = azurerm_lb_backend_address_pool.Mary-W-Jackson-backend-PRO.id

  frontend_ip_configuration {
    name = "Mary-W-Jackson-frontend-PRO"
  }
}

