#Option to use AppGateway if a public IP is wanted. Autoscaling option is only available on v2, but this does not support private IP only.

// module "AppGateway"{
//     source                = "../../modules/ApplicationGW"

//     name                  = "gw-uks-prod-01"
//     rg                    = module.ResourceGroup.rg_name
//     location              = module.ResourceGroup.rg_location
//     zones                 = ["1","2","3"]
//     website_path          = "/hello-world.http"

//     sku_name              = "standard_medium"
//     sku_tier              = "standard"

//     min_capacity          = 2
//     max_capacity          = 10

//     gateway_snet_id       = module.subnet_gateway.snet_id
//     ipconf_front_ip       = "10.0.0.4"
// }

resource "azurerm_application_gateway" "main" {
  name                = var.name
  resource_group_name = var.rg
  location            = var.location
  zones               = var.zones

  autoscale_configuration{
    min_capacity = var.min_capacity
    max_capacity = var.max_capacity
  }

  sku {
    name     = var.sku_name
    tier     = var.sku_tier
    #Capacity gets overwritten by scaling options (above) but terraform has this as mandatory...
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "${var.name}-ipconf"
    subnet_id = var.gateway_snet_id
  }

  frontend_port {
    name = "${var.name}-feipport"
    port = 80
  }

  frontend_ip_configuration {
    name                            = "${var.name}-feip"
    subnet_id                       = var.gateway_snet_id
    private_ip_address_allocation   = "Static"
    private_ip_address              = var.ipconf_front_ip
  }

  backend_address_pool {
    name = "${var.name}-bap"
  }

  backend_http_settings {
    name                  = "${var.name}-settingshttp"
    cookie_based_affinity = "Disabled"
    path                  = var.website_path
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  backend_http_settings {
    name                  = "${var.name}-settingshttps"
    cookie_based_affinity = "Disabled"
    path                  = var.website_path
    port                  = 443
    protocol              = "Https"
    request_timeout       = 60
  }

  http_listener {
    name                           = "${var.name}-listenerhttp"
    frontend_ip_configuration_name = "${var.name}-feip"
    frontend_port_name             = "${var.name}-feipport"
    protocol                       = "Http"
  }

  http_listener {
    name                           = "${var.name}-listenerhttps"
    frontend_ip_configuration_name = "${var.name}-feip"
    frontend_port_name             = "${var.name}-feipport"
    protocol                       = "Https"
  }

  request_routing_rule {
    name                       = "${var.name}-rrrhttp"
    rule_type                  = "Basic"
    http_listener_name         = "${var.name}-listenerhttp"
    backend_address_pool_name  = "${var.name}-bap"
    backend_http_settings_name = "${var.name}-settingshttp"
  }

  request_routing_rule {
    name                       = "${var.name}-rrrhttps"
    rule_type                  = "Basic"
    http_listener_name         = "${var.name}-listenerhttps"
    backend_address_pool_name  = "${var.name}-bap"
    backend_http_settings_name = "${var.name}-settingshttps"
  }
}