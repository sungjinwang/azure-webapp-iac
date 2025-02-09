terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = var.azurerm_version
    }
  }
}

provider "azurerm" {
  features {}
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-webapp-cus"
  location = "centralus"
}