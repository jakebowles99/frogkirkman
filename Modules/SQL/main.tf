resource "azurerm_mysql_server" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.rg

  create_mode               = var.create_mode
  creation_source_server_id = var.create_mode == "Default" ? null : var.create_source_id

  administrator_login          = var.admin
  administrator_login_password = var.password

  sku_name   = var.sku
  storage_mb = var.size
  version    = "5.7"

  # recommended default settings
  auto_grow_enabled                 = true
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = false
  infrastructure_encryption_enabled = false
  public_network_access_enabled     = true
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"

  tags = var.tags
}