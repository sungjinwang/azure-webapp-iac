resource "azurerm_key_vault" "kv" {
  name                        = "keyvault-cus"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name                    = "standard"

  enable_rbac_authorization = true
}

# Secret 생성
resource "azurerm_key_vault_secret" "kv_secret" {
  name         = var.secret.name
  value        = var.secret.value
  key_vault_id = azurerm_key_vault.kv.id
}

# Role assignment
resource "azurerm_role_assignment" "kv_access_web1" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_virtual_machine.vm_web1.identity[0].principal_id
}

# Role assignment
resource "azurerm_role_assignment" "kv_access_web2" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_virtual_machine.vm_web2.identity[0].principal_id
}