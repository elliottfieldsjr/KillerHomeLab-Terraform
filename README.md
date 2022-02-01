# Collection of Labs to Deploy within Azure for Self-Study or Proof Of Concept

# Active Directory Single-Site
[![ActiveDirectory-Single-Site](https://github.com/elliottfieldsjr/KillerHomeLab-Bicep/actions/workflows/ActiveDirectory-Single-Site.yml/badge.svg)](https://github.com/elliottfieldsjr/KillerHomeLab-Terraform/actions/workflows/ActiveDirectory-Single-Site.yml)
<a href="./Deployments/ActiveDirectory-Single-Site"><img src="Deployments/x_Images/ActiveDirectorySingleSite.png" alt="Active Directory Single-Site" width="150"></a>

The following deployments include various Azure Lab scenarios, inlcuding both Cloud Native as well as On-Prem Solutions.  Although the deployment of these labs are automated, some required infrastructue must be created prior to deployment.  These items are listed below:

- Azure Service Principal
- GitHub Secrets
- Azure Storage Account (Utilized for Terraform State)
- Azure Key Vault (Utilized for Virtual Machine Username/Password)

# Create an Azure Service Principal
From Azure Cloud Shell run the following command:

az ad sp create-for-rbac --name "[ENTER SP NAME HERE]" --role owner --scopes /subscriptions/[ENTER SUB ID HERE] --sdk-auth

The output should look like the output shown below however we only need to notate "clientId", "clientSecret", "subscriptionId" and "tenantId"

{ <br>
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", <br>
  "clientSecret": "xxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxx", <br>
  "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", <br>
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", <br>
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com", <br>
  "resourceManagerEndpointUrl": "https://management.azure.com/", <br>
  "activeDirectoryGraphResourceId": "https://graph.windows.net/", <br>
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/", <br>
  "galleryEndpointUrl": "https://gallery.azure.com/", <br>
  "managementEndpointUrl": "https://management.core.windows.net/" <br>
} <br>

# Create GitHub Secrets
GitHub secrets are used to store the values that construct your Azure Service Principal for use within GitHub Actions.  Follow the steps in the article below to create the following GitHub Secrets.

- MIC_SUB1_CLIENT_ID
- MIC_SUB1_CLIENT_SECRET
- MIC_SUB1_SUBSCRIPTION_ID
- MIC_SUB1_TENANT_ID

[![Create Secrets for GitHub workflows]](https://github.com/Azure/actions-workflow-samples/blob/master/assets/create-secrets-for-GitHub-workflows.md#:~:text=%20Creating%20secrets%20%201%20On%20GitHub%2C%20navigate,your%20secret.%207%20Click%20Add%20secret.%20More%20)

# Create Azure Storage Account and Container
Create a v2 Azure Storage Account and a Container.  Notate both the Storage Account and Container Name for later usage.

# Create Azure Key Vault and Secret
Create an Azure Key Vault and a Secret called adminPassword that will contain the password used for each VM created. Notate both the Key Vault Name and ResourceID for later usage.

In order to use this Repo simply clone it and modify the following files:

main.tf <br>

Modify the following section to include the information notated from above Regarding your Azure Storage Account

terraform { <br>
  backend "azurerm" { <br>
    resource_group_name  = "[Enter Storage Account Resource Group Name Here]" <br>
    storage_account_name = "[Enter Storage Account Name Here]" <br>
    container_name       = "[Enter Storage Account Container Name Here]" <br>
    key                  = "deployment.tfstate" <br>
  } <br>

inputs.tfvars <br>

Modify the following section to include the information notated from above Regarding your Azure Key Vault

KeyVaultName              = "KHL-Terraform-KeyVault1" <br>
KeyVaultResourceId        = "/subscriptions/6bdf26a8-4bbb-4fcf-be0a-7f3f912e7705/resourceGroups/TerraForm-Infra/providers/Microsoft.KeyVault/vaults/KHL-Terraform-KeyVault1" <br>

The following variables within the "inputs.tfvars" can also be modified to customize your deployment however are optional:

ResourceGroupName1        = "ActiveDirectory-Single-Site-TF-EUS" <br>
Location1                 = "eastus" <br>
TimeZone1                 = "Eastern Standard Time" <br>
adminUsername             = "dom-admin" <br>
adminPasswordName         = "adminPassword" <br>
WindowsServerLicenseType  = "Windows_Server" <br>
WindowsClientLicenseType  = "Windows_Client" <br>
NamingConvention          = "khl" <br>
SubDNSDomain              = "" <br>
SubDNSBaseDN              = "" <br>
NetBiosDomain             = "killerhomelab" <br>
InternalDomain            = "killerhomelab" <br>
InternalTLD               = "com" <br>
vnet1ID                   = "10.1" <br>
DC1OSVersion              = "2022-Datacenter" <br>
dc1vmsize                 = "Standard_D2s_v3" <br>