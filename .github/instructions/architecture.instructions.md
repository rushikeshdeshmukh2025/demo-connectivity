# Demo for Azure connectivity

This will demo the Azure Network Setup using virtual WAN hub and shared services virtual network.

***Modules***

Create below terraform modules in the /modules directory refer to azure verified modules

    1. Azure virtual WAN
    2. Azure Virtual WAN hub
    3. Azure Virtual Network
    4. Azure Virtual Network Peering
    5. Azure Firewall Policy
    6. Azure Firewall
    7. Network Security Group
    8. Application Security Group
    9. Azure Bastion
    10. IP pool

***Steps***

 Deploy below infrastructure as provided below

    1. Deploy Azure IP pool with IP address range 10.0.0.0/16 for the virtual WAN hub and shared services virtual network
    2. Create Azure virtual WAN
    3. Create Azure Virtual WAN hub. Select /23 ip address from the ip pool.
    4. Deploy Azure Firewall policy and Azure Firewall in the virtual WAN hub
    5. Create virtual network gateway in the virtual WAN hub, don't create any connection yet
    6. Create shared services virtual network. Select /23 IP address range from IP pools and add below subnets
         a. Azure Bastion subnet (/27)
         b. private endpoint subnet (/27)
         c. App subnet (/27)
    7. Create Default NSG and  and associate with shared services virtual network
    8. All resource should be created in Germany West Central region

***Best practices***

    1. Use latest stable Terraform version: 1.13.0 or later.
    2. Use latest stable provider versions.
    3. Generate terraform resources code for azurerm provider version 4.0.0 or later, NOT for 3.x or earlier.
    4. Follow Azure Best practices for network security and segmentation.
    5. Follow naming conventions for the resources and variables.
    6. Use Terraform modules to organize and reuse code.

***Naming conventions***

   Modules Names

        1. Use only low case letters and underscores in tf file names.
        2. Modules and resources names should reflect the purpose, prior resource type.

   Resource Names

    
        1. Use only low case letters and underscores in tf file names.
        2. perfix resource names like for example

            - resource group:  
rg_<company_prefix>_<environment>_<purpose>_<region>

        3. Company prefix: use 3 letter `rus`
        
            - Environment: dev, test, pt, live, global, rnd
            - Purpose: short name reflecting the purpose of the resource
            - Region: short name of the region for example  `gwc` for `germany west central`