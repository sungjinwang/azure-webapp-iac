# Azure credentials
tenant_id       = "XXXX-XXXX-XXXX-XXXX-XXXX"
subscription_id = "XXXX-XXXX-XXXX-XXXX-XXXX"
client_id       = "XXXX-XXXX-XXXX-XXXX-XXXX"
client_secret   = "XXXXXXXXXXXXXXXXXXXXXXXX"

# Vnet
address_space   = ["10.0.0.0/16"]

# Subnet
subnets = {
  "subnet-bastion" = { address_prefix = "10.0.0.0/24", outbound = true }
  "subnet-natgw"   = { address_prefix = "10.0.1.0/24", outbound = true }
  "subnet-web1"    = { address_prefix = "10.0.2.0/24", outbound = false }
  "subnet-web2"    = { address_prefix = "10.0.3.0/24", outbound = false }
  "subnet-db1"     = { address_prefix = "10.0.4.0/24", outbound = false }
  "subnet-db2"     = { address_prefix = "10.0.5.0/24", outbound = false }
  "subnet-lb"      = { address_prefix = "10.0.6.0/24", outbound = true }
}

# NSG 
nsgs = {
  nsg-bastion = {
    rules = [
      {
        name                       = "Allow-SSH"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_ranges           = ["0-65535"]
        destination_port_ranges      = ["22"]
        source_address_prefixes      = ["0.0.0.0/0"] # 관리자 IP
        destination_address_prefixes = ["10.0.0.4"]  # Bastion IP (Private IP)
      }
    ]
  }
  nsg-web1 = {
    rules = [
      {
        name                       = "Allow-Bastion-SSH"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_ranges           = ["0-65535"]
        destination_port_ranges      = ["22"]
        source_address_prefixes      = ["10.0.0.4"] # Bastion IP
        destination_address_prefixes = ["10.0.2.4"] # Web1 IP
      },
      {
        name                       = "Allow-HTTP"
        priority                   = 200
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_ranges           = ["0-65535"]
        destination_port_ranges      = ["80"]
        source_address_prefixes      = ["0.0.0.0/0"]
        destination_address_prefixes = ["10.0.2.4"] # Web1 IP
      },
      {
        name                       = "Allow-Mysql"
        priority                   = 300
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_ranges           = ["0-65535"]
        destination_port_ranges      = ["3306"]
        source_address_prefixes      = ["10.0.4.4"] # DB1 IP
        destination_address_prefixes = ["10.0.2.4"] # Web1 IP
      },
      {
        name                       = "Deny-Inbound"
        priority                   = 400
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_ranges           = ["0-65535"]
        destination_port_ranges      = ["0-65535"]
        source_address_prefixes      = ["0.0.0.0/0"] # 지정한 IP 제외 모든 IP
        destination_address_prefixes = ["10.0.2.4"]  # Web1 IP
      },
      {
        name                       = "Deny-Outbound"
        priority                   = 100
        direction                  = "Outbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_ranges           = ["0-65535"]
        destination_port_ranges      = ["0-65535"]
        source_address_prefixes      = ["10.0.2.4"]  # Web1 IP
        destination_address_prefixes = ["10.0.3.4", "10.0.5.4"] # Web2, DB2
      },
    ]
  }
  nsg-web2 = {
    rules = [
      {
        name                       = "Allow-Bastion-SSH"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_ranges           = ["0-65535"]
        destination_port_ranges      = ["22"]
        source_address_prefixes      = ["10.0.0.4"] # Bastion IP
        destination_address_prefixes = ["10.0.3.4"] # Web2 IP
      },
      {
        name                       = "Allow-HTTP"
        priority                   = 200
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_ranges           = ["0-65535"]
        destination_port_ranges      = ["80"]
        source_address_prefixes      = ["0.0.0.0/0"]
        destination_address_prefixes = ["10.0.3.4"] # Web2 IP
      },
      {
        name                       = "Allow-Mysql"
        priority                   = 300
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_ranges           = ["0-65535"]
        destination_port_ranges      = ["3306"]
        source_address_prefixes      = ["10.0.4.4"] # DB1 IP
        destination_address_prefixes = ["10.0.3.4"] # Web2 IP
      },
      {
        name                       = "Deny-Inbound"
        priority                   = 400
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_ranges           = ["0-65535"]
        destination_port_ranges      = ["0-65535"]
        source_address_prefixes      = ["0.0.0.0/0"] # 지정한 IP 제외 모든 IP
        destination_address_prefixes = ["10.0.3.4"] # Web2 IP
      },
      {
        name                       = "Deny-Outbound"
        priority                   = 100
        direction                  = "Outbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_ranges           = ["0-65535"]
        destination_port_ranges      = ["0-65535"]
        source_address_prefixes      = ["10.0.3.4"] # Web2 IP
        destination_address_prefixes = ["10.0.2.4", "10.0.5.4"] # Web1, DB2
      },
    ]
  }
  nsg-db1 = {
    rules = [
      {
        name                       = "Allow-Bastion-SSH"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_ranges           = ["0-65535"]
        destination_port_ranges      = ["22"]
        source_address_prefixes      = ["10.0.0.4"] # Bastion IP
        destination_address_prefixes = ["10.0.4.4"] # DB1 IP
      },
      {
        name                       = "Allow-MySQL"
        priority                   = 200
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_ranges           = ["0-65535"]
        destination_port_ranges      = ["3306"]
        source_address_prefixes      = ["10.0.2.4", "10.0.3.4", "10.0.5.4"] # Web1, Web2, DB2
        destination_address_prefixes = ["10.0.4.4"] # DB1 IP
      },
      {
        name                       = "Deny-Inbound"
        priority                   = 300
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_ranges           = ["0-65535"]
        destination_port_ranges      = ["0-65535"]
        source_address_prefixes      = ["0.0.0.0/0"] # 지정한 IP 제외 모든 IP
        destination_address_prefixes = ["10.0.4.4"]  # DB1 IP
      },
      {
        name                       = "Allow-Outbound"
        priority                   = 100
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_ranges           = ["0-65535"]
        destination_port_ranges      = ["3306"]
        source_address_prefixes      = ["10.0.4.4"] # DB1 IP
        destination_address_prefixes = ["10.0.2.4", "10.0.3.4", "10.0.5.4"] # Web1, Web2, DB2
      },
      {
        name                       = "Deny-Outbound"
        priority                   = 200
        direction                  = "Outbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_ranges           = ["0-65535"]
        destination_port_ranges      = ["0-65535"]
        source_address_prefixes      = ["10.0.4.4"]  # DB1 IP
        destination_address_prefixes = ["0.0.0.0/0"] # 지정한 IP 제외 모든 IP
      }
    ]
  }
  nsg-db2 = {
    rules = [
      {
        name                       = "Allow-Bastion-SSH"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_ranges           = ["0-65535"]
        destination_port_ranges      = ["22"]
        source_address_prefixes      = ["10.0.0.4"] # Bastion IP
        destination_address_prefixes = ["10.0.5.4"] # DB2 IP
      },
      {
        name                       = "Allow-MySQL"
        priority                   = 200
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_ranges           = ["0-65535"]
        destination_port_ranges      = ["3306"]
        source_address_prefixes      = ["10.0.4.4"] # DB1 IP
        destination_address_prefixes = ["10.0.5.4"] # DB2 IP
      },
      {
        name                       = "Deny-Inbound"
        priority                   = 300
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_ranges           = ["0-65535"]
        destination_port_ranges      = ["0-65535"]
        source_address_prefixes      = ["0.0.0.0/0"] # 지정한 IP 제외 모든 IP
        destination_address_prefixes = ["10.0.5.4"]  # DB2 IP
      },
      {
        name                       = "Allow-Outbound"
        priority                   = 100
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_ranges           = ["0-65535"]
        destination_port_ranges      = ["3306"]
        source_address_prefixes      = ["10.0.5.4"] # DB2 IP
        destination_address_prefixes = ["10.0.4.4"] # DB1
      },
      {
        name                       = "Deny-Outbound"
        priority                   = 200
        direction                  = "Outbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_ranges           = ["0-65535"]
        destination_port_ranges      = ["0-65535"]
        source_address_prefixes      = ["10.0.5.4"]  # DB2 IP
        destination_address_prefixes = ["0.0.0.0/0"] # 지정한 IP 제외 모든 IP
      }
    ]
  }
}

# NIC
nic_configs = [
  {
    name               = "bastion-nic"
    ipconfig_name      = "bastion-ipconfig"
    subnet_key         = "subnet-bastion"
    public_ip_required = true
    public_ip_key      = "bastion-ip"
  },
  {
    name               = "web1-nic"
    ipconfig_name      = "web1-ipconfig"
    subnet_key         = "subnet-web1"
    public_ip_required = false
  },
  {
    name               = "web2-nic"
    ipconfig_name      = "web2-ipconfig"
    subnet_key         = "subnet-web2"
    public_ip_required = false
  },
  {
    name               = "db1-nic"
    ipconfig_name      = "db1-ipconfig"
    subnet_key         = "subnet-db1"
    public_ip_required = false
  },
  {
    name               = "db2-nic"
    ipconfig_name      = "db2-ipconfig"
    subnet_key         = "subnet-db2"
    public_ip_required = false
  }
]

# Public IP
public_ips = {
  bastion-ip = {
    allocation_method = "Static"
    sku               = "Standard"
  }
  natgw-ip = {
    allocation_method = "Static"
    sku               = "Standard"
  }
  lb-ip = {
    allocation_method = "Static"
    sku               = "Standard"
  }
}

# VM
vm_admin_username = "sjwang"
public_key_path = "~/.ssh/id_rsa.pub"
vm_size = "Standard_F1s"
os_disk = {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
}
image_reference = {
    publisher = "resf"
    offer     = "rockylinux-x86_64"
    sku       = "9-lvm"
    version   = "latest"
  }
plan = {
    name      = "9-lvm"
    publisher = "resf"
    product   = "rockylinux-x86_64"
}

# Key vault
secret = {
  name  = "mysql-password"
  value = "Password1234!"
}