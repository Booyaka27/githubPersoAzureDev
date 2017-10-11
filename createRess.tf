#Create a ressource Group

resource "azurerm_resource_group" "testSL-TF001" {
    name = "testSL-TF001"
    location = "westeurope"
    tags {
        environment = "test"
        project = "terraformAutoTraining"
        domain = "IOS-IPO"
    }  
}


# Compte de stockage
# Storage Account
resource "azurerm_storage_account" "testSL-TF001-StorAccount" {
  name                = "storageaccountpackertestsl001"
  resource_group_name = "${azurerm_resource_group.testSL-TF001.name}"
  location            = "${azurerm_resource_group.testSL-TF001.location}"
  account_type        = "Standard_LRS"
}

# Container dans le compte de stockage
resource "azurerm_storage_container" "testSL-TF001-Container" {
   name = "VM-images"
   resource_group_name = "${azurerm_resource_group.testSL-TF001.name}"
   storage_account_name = "${azurerm_storage_account.testSL-TF001-StorAccount.name}"
   container_access_type = "private"
}