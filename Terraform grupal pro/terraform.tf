#Archivo para datos del proveedor
terraform {
    required_providers {
        azurerm= { 
            source = "hashicorp/azurerm" 
            version ="4.64.0" 
        } 
    } 
} 
#Damos los datos de la cuenta de nuestro proveedor
provider "azurerm" {
    features {}
}