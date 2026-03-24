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
#Damos los datos de la cuenta de nuestro proveedor
provider "azurerm" {
    features {}
}