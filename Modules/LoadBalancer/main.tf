resource "azurerm_lb" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.rg
  sku                 = "standard"
  tags                = var.tags

  frontend_ip_configuration {
    name                 = "${var.name}-feip"
    subnet_id            = var.snet_id
    private_ip_address   = var.private_ip
  }
}

resource "azurerm_lb_backend_address_pool" "main" {
  resource_group_name = var.rg
  loadbalancer_id     = azurerm_lb.main.id
  name                = "${var.name}-beap"
}

resource "azurerm_lb_nat_pool" "http" {
  resource_group_name            = var.rg
  name                           = "http"
  loadbalancer_id                = azurerm_lb.main.id
  protocol                       = "Tcp"
  frontend_port_start            = 50000
  frontend_port_end              = 50119
  backend_port                   = 80
  frontend_ip_configuration_name = "${var.name}-feip"
}

resource "azurerm_lb_nat_pool" "https" {
  resource_group_name            = var.rg
  name                           = "https"
  loadbalancer_id                = azurerm_lb.main.id
  protocol                       = "Tcp"
  frontend_port_start            = 60000
  frontend_port_end              = 60119
  backend_port                   = 443
  frontend_ip_configuration_name = "${var.name}-feip"
}

resource "azurerm_lb_probe" "http" {
  resource_group_name = var.rg
  loadbalancer_id     = azurerm_lb.main.id
  name                = "http-probe"
  protocol            = "Http"
  request_path        = var.website_path
  port                = 80
}

resource "azurerm_lb_probe" "https" {
  resource_group_name = var.rg
  loadbalancer_id     = azurerm_lb.main.id
  name                = "https-probe"
  protocol            = "Https"
  request_path        = var.website_path
  port                = 443
}
