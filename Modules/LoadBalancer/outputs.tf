output "lb_bap_id" {
  value = azurerm_lb_backend_address_pool.main.id
}

output "http_nat_id" {
  value = azurerm_lb_nat_pool.http.id
}

output "https_nat_id" {
  value = azurerm_lb_nat_pool.https.id
}

output "probe_id" {
  value = azurerm_lb_probe.http.id
}