#Archivo para datos del proveedor
terraform {
    required_providers {
        azurerm= { 
            source = "hashicorp/azurerm" 
            version ="4.64.0" 
        } 
    } 
} 

terraform {  
    backend "azurerm" {
        resource_group_name  = "RG_OhMyGit"
        storage_account_name = "terratfsa12345"
        container_name       = "tfstate"
        key                  = "terraform.tfstate"
    }
}

#Damos los datos de la cuenta de nuestro proveedor
provider "azurerm" {
    features {}
}