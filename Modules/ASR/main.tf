resource "azurerm_recovery_services_vault" "vault" {
  name                = var.rsv_name
  location            = var.rsv_location
  resource_group_name = var.rg_second_name
  sku                 = var.rsv_sku
  tags                = var.tags

}

resource "azurerm_site_recovery_replication_policy" "policy" {
  name                                                 = "policy"
  resource_group_name                                  = var.rg_second_name
  recovery_vault_name                                  = var.rg_second_location
  recovery_point_retention_in_minutes                  = 24 * 60
  application_consistent_snapshot_frequency_in_minutes = 4 * 60
}

resource "azurerm_site_recovery_fabric" "primary" {
  name                = var.primary_fabric_name
  resource_group_name = var.rg_second_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  location            = var.rg_primary_location

  depends_on = [
    azurerm_recovery_services_vault.vault,
  ]
}

resource "azurerm_site_recovery_fabric" "secondary" {
  name                = var.secondary_fabric_name
  resource_group_name = var.rg_second_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  location            = var.rg_second_location

  depends_on = [
    azurerm_site_recovery_fabric.primary,
  ]
}

resource "azurerm_site_recovery_protection_container" "primary" {
  name                 = var.primary_protection_container
  resource_group_name  = var.rg_second_name
  recovery_vault_name  = azurerm_recovery_services_vault.vault.name
  recovery_fabric_name = azurerm_site_recovery_fabric.primary.name
}

resource "azurerm_site_recovery_protection_container" "secondary" {
  name                 = var.secondary_protection_container
  resource_group_name  = var.rg_second_name
  recovery_vault_name  = azurerm_recovery_services_vault.vault.name
  recovery_fabric_name = azurerm_site_recovery_fabric.secondary.name
}

resource "azurerm_site_recovery_protection_container_mapping" "container-mapping" {
  name                                      = "container-mapping"
  resource_group_name                       = var.rg_second_name
  recovery_vault_name                       = azurerm_recovery_services_vault.vault.name
  recovery_fabric_name                      = azurerm_site_recovery_fabric.primary.name
  recovery_source_protection_container_name = azurerm_site_recovery_protection_container.primary.name
  recovery_target_protection_container_id   = azurerm_site_recovery_protection_container.secondary.id
  recovery_replication_policy_id            = azurerm_site_recovery_replication_policy.policy.id
}

resource "azurerm_storage_account" "primary" {
  name                     = "jbtstaccoun238699"
  location                 = var.rg_primary_location
  resource_group_name      = var.rg_primary_name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_virtual_network" "secondary" {
  name                = var.secondary_vnet_name
  resource_group_name = var.rg_second_name
  address_space       = var.secondary_vnet_address_space
  location            = var.rg_second_location
}

resource "azurerm_subnet" "secondary" {
  name                 = var.secondary_vnet_subnet1
  resource_group_name  = var.rg_second_name
  virtual_network_name = azurerm_virtual_network.secondary.name
  address_prefixes     = var.secondary_subnet_address_space
}

resource "azurerm_site_recovery_replicated_vm" "vm-replication" {
  name                                      = var.replicated_vm_name
  resource_group_name                       = var.rg_second_name
  recovery_vault_name                       = azurerm_recovery_services_vault.vault.name
  source_recovery_fabric_name               = azurerm_site_recovery_fabric.primary.name
  source_vm_id                              = var.source_vm_id
  recovery_replication_policy_id            = azurerm_site_recovery_replication_policy.policy.id
  source_recovery_protection_container_name = azurerm_site_recovery_protection_container.primary.name

  target_resource_group_id                = var.rg_second_id
  target_recovery_fabric_id               = azurerm_site_recovery_fabric.secondary.id
  target_recovery_protection_container_id = azurerm_site_recovery_protection_container.secondary.id

  managed_disk {
    disk_id                    = var.os_disk_id
    staging_storage_account_id = azurerm_storage_account.primary.id
    target_resource_group_id   = var.rg_second_id
    target_disk_type           = "Premium_LRS"
    target_replica_disk_type   = "Premium_LRS"
  }
}

