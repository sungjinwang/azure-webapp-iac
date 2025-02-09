# azurerm_version
variable "azurerm_version" {
  type = string
  default = "4.16.0"
}

# Azure Credentials
variable "tenant_id" {
    type = string
}

variable "subscription_id" {
    type = string
}

variable "client_id" {
    type = string
}

variable "client_secret" {
    type = string
}

# Vnet
variable "address_space" {
  type = list(string)
}

# Subnet
variable "subnets" {
  type = map(object({
    address_prefix = string
    outbound       = bool
  }))
}

# NSG
variable "nsgs" {
  type = map(object({
    rules = list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_ranges           = list(string)
      destination_port_ranges      = list(string)
      source_address_prefixes      = list(string)
      destination_address_prefixes = list(string)
    }))
  }))
}

# NIC
variable "nic_configs" {
  type = list(object({
    name               = string 
    ipconfig_name      = string
    subnet_key         = string
    public_ip_required = bool 
    public_ip_key      = optional(string)  
  }))
}

# Public IP
variable "public_ips" {
  type = map(object({
    allocation_method = string
    sku               = string
  }))
}

# VM
variable "vm_admin_username" {
  type        = string
}

variable "public_key_path" {
  type        = string
}

variable "vm_size" {
  type        = string
}

variable "os_disk" {
  type = object({
    caching = string
    storage_account_type = string
  })
}

variable "image_reference" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}

variable "plan" {
  type = object({
    name      = string
    publisher = string
    product   = string
  })
}

# Key vault
variable "secret" {
  type = object({
    name  = string
    value = string
  })
}
