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