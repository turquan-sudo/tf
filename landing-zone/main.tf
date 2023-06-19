terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "ml" {
  name     = var.resource_group_ml.name
  location = var.esource_group_ml.location
}

resource "azurerm_resource_group" "adf" {
  name     = var.resource_group_adf.name
  location = var.esource_group_adf.location
}