#Archivo para datos del proveedor
terraform {
    required_providers {
        azurerm= { 
            source = "hashicorp/azurerm" 
            version ="4.64.0" 
        }
        kubernetes = {
            source  = "hashicorp/kubernetes"
            version = "~> 2.27"
        }

        helm = {
            source  = "hashicorp/helm"
            version = "~> 2.12"
        } 
    } 
} 
terraform {  
    backend "azurerm" {
        resource_group_name  = "RG_OhMyGit"
        storage_account_name = "terratfsa12345pro"
        container_name       = "tfstate"
        key                  = "terraform.tfstate"
    }
}
#Damos los datos de la cuenta de nuestro proveedor
provider "azurerm" {
    features {}
}