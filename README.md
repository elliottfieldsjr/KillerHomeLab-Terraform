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

{
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret": "xxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxx",
  "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}

# Create GitHub Secrets
GitHub secrets are used to store the values that construct your Azure Service Principal for use within GitHub Actions.  Follow the steps in the article below to create the following GitHub Secrets.

- MIC_SUB1_CLIENT_ID
- MIC_SUB1_CLIENT_SECRET
- MIC_SUB1_SUBSCRIPTION_ID
- MIC_SUB1_TENANT_ID

https://github.com/Azure/actions-workflow-samples/blob/master/assets/create-secrets-for-GitHub-workflows.md#:~:text=%20Creating%20secrets%20%201%20On%20GitHub%2C%20navigate,your%20secret.%207%20Click%20Add%20secret.%20More%20

# Create Azure Storage Account and Container
Create a v2 Azure Storage Account and a Container.  Notate both the Storage Account and Container Name for later usage.

# Create Azure Key Vault and Secret
Create an Azure Key Vault and a Secret called adminPassword that will contain the password used for each VM created. Notate both the Key Vault Name and ResourceID for later usage.

In order to use this Repo simply clone it and modify the following files:


