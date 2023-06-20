#Providers
terraform {
  required_providers {
    azurerm = {
      source    = "hashicorp/azurerm"
      version   = ">= 2.26"
    }
  }
}
provider "azurerm" {
  subscription_id = "332236a1-0cc9-46f9-be63-4d52b10598eb"
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}