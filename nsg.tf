module "network_security_group_private_endpoint" {
  source = "./modules/network_security_group"

  name                = "nsg_${local.name_prefix}_private_endpoint_${local.name_suffix}"
  resource_group_name = azurerm_resource_group.shared_services.name
  location            = var.location

  subnet_ids = {
    private_endpoint = module.shared_services_vnet.subnet_ids["private_endpoint"]
  }

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

module "network_security_group_app" {
  source = "./modules/network_security_group"

  name                = "nsg_${local.name_prefix}_app_${local.name_suffix}"
  resource_group_name = azurerm_resource_group.shared_services.name
  location            = var.location

  subnet_ids = {
    app = module.shared_services_vnet.subnet_ids["app"]
  }

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}
module "network_security_group_bastion" {
  source = "./modules/network_security_group"

  name                = "nsg_${local.name_prefix}_bastion_${local.name_suffix}"
  resource_group_name = azurerm_resource_group.shared_services.name
  location            = var.location

  subnet_ids = {
    bastion = module.shared_services_vnet.subnet_ids["bastion"]
  }

  security_rules = {
    # ── Inbound ────────────────────────────────────────────────────────────
    allow_https_inbound = {
      name                       = "AllowHttpsInbound"
      priority                   = 120
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
    }
    allow_gateway_manager_inbound = {
      name                       = "AllowGatewayManagerInbound"
      priority                   = 130
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "GatewayManager"
      destination_address_prefix = "*"
    }
    allow_azure_load_balancer_inbound = {
      name                       = "AllowAzureLoadBalancerInbound"
      priority                   = 140
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "AzureLoadBalancer"
      destination_address_prefix = "*"
    }
    allow_bastion_host_communication_8080 = {
      name                       = "AllowBastionHostCommunicationInbound8080"
      priority                   = 150
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "8080"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
    }
    allow_bastion_host_communication_5701 = {
      name                       = "AllowBastionHostCommunicationInbound5701"
      priority                   = 160
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "5701"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
    }
    deny_all_inbound = {
      name                       = "DenyAllInbound"
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
    # ── Outbound ───────────────────────────────────────────────────────────
    allow_ssh_rdp_outbound = {
      name                       = "AllowSshRdpOutbound"
      priority                   = 100
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "VirtualNetwork"
    }
    allow_rdp_outbound = {
      name                       = "AllowRdpOutbound"
      priority                   = 101
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3389"
      source_address_prefix      = "*"
      destination_address_prefix = "VirtualNetwork"
    }
    allow_azure_cloud_outbound = {
      name                       = "AllowAzureCloudOutbound"
      priority                   = 110
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "AzureCloud"
    }
    allow_bastion_communication_8080_outbound = {
      name                       = "AllowBastionCommunicationOutbound8080"
      priority                   = 120
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "8080"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
    }
    allow_bastion_communication_5701_outbound = {
      name                       = "AllowBastionCommunicationOutbound5701"
      priority                   = 130
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "5701"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
    }
    deny_all_outbound = {
      name                       = "DenyAllOutbound"
      priority                   = 4096
      direction                  = "Outbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "Internet"
    }
  }

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}
