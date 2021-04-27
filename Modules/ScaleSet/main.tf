resource "azurerm_virtual_machine_scale_set" "main" {
  name                = var.scale_set_name
  location            = var.location
  resource_group_name = var.rg
  zones               = var.zones

  automatic_os_upgrade = false
  upgrade_policy_mode  = "Manual"

  tags                 = var.tags

  sku {
    name     = var.SKU_name
    tier     = "Standard"
    capacity = 2
  }

  storage_profile_image_reference {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.image_sku
    version   = "latest"
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = var.disk_sku
  }

  os_profile {
    computer_name_prefix = var.scale_set_name
    admin_username       = var.username
    admin_password       = var.password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  network_profile {
    name    = "terraformnetworkprofile"
    primary = true

    ip_configuration {
      name                                   = "IPConfiguration"
      primary                                = true
      subnet_id                              = var.subnet_id
      load_balancer_backend_address_pool_ids = [var.backend_addpool_id]
      load_balancer_inbound_nat_rules_ids    = var.nat_ids
    }
  }
}

resource "azurerm_monitor_autoscale_setting" "main" {
  name                = "AutoscaleSetting"
  resource_group_name = var.rg
  location            = var.location
  target_resource_id  = azurerm_virtual_machine_scale_set.main.id

  profile {
    name = "defaultProfile"

    capacity {
      default = var.default_vm
      minimum = var.min_vm
      maximum = var.max_vm
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_virtual_machine_scale_set.main.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = var.increase_percentage
        metric_namespace   = "microsoft.compute/virtualmachinescalesets"
        dimensions {
          name     = "AppName"
          operator = "Equals"
          values   = ["App1"]
        }
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_virtual_machine_scale_set.main.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = var.decrease_percentage
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }
}