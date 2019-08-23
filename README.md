# Azure AD Application Management

[![Build status](https://ralphjansen.visualstudio.com/AzureAdApplicationManagement/_apis/build/status/Vsts-Extension?branchName=master)](https://ralphjansen.visualstudio.com/AzureAdApplicationManagement/_build/latest?definitionId=12&branchName=master)

Azure AD Application Management with VSTS pipeline tasks. These VSTS tasks are created with and tested on **Hosted Visual Studio 2017** agents.

This VSTS extension contains the following tasks:

- Get Azure AD Application
- New Azure AD Application
- Set Azure AD Application (recommended)
- Remove Azure AD Application

In order to use these tasks, follow the **prerequisite** steps in the [Get Started](#get-started) section.

## Get Started

In order to use these tasks, a **prerequisite must be done** otherwise you will get an **unauthorized error**. Follow the steps below to fix the permission issue:

1. Create an Azure Resource Manager endpoint in your VSTS team project manually or let VSTS create one for you.
2. Go to the [Azure portal](https://portal.azure.com)
3. In the Azure portal, navigate to **App Registrations**
4. Select the created app registration. If you can't find it, you probably don't have the right permissions. You can still find the app registration by changing the tab to **All applications**.
5. Check the **Owners** of the selected app registration (application). If your not an owner, find an **owner** or a **Global Administrator** (you will need a Global Admin in the next steps).
6. Set the **API Permissions** at least with the following permissions **Azure Active Directory Graph** with the **application** permissions **Manage apps that this app creates or owns (Application.ReadWrite.OwnedBy)** and **Read directory data (Directory.Read.All)**. When you save this, this will result in the following array in the **manifest**:

    ```json
    "requiredResourceAccess": [
      {
        "resourceAppId": "00000002-0000-0000-c000-000000000000",
        "resourceAccess": [
          {
            "id": "824c81eb-e3f8-4ee6-8f6d-de7f50d565b7",
            "type": "Role"
          },
          {
            "id": "5778995a-e1bf-45b8-affa-663a9f3f4d04",
            "type": "Role"
          }
        ]
      }
    ]
    ```

7. **Very important** Request an Azure Global Administrator to hit the button **Grant admin consent for {your company}** in the **API permissions** view. This only has to be done once.
8. Use any task of this extension.

## FAQ

### How can I manage an already created AD Application

Set the [owner of the AD Application to the AD Application](#How-can-I-set-an-AD-Application-as-owner-of-an-AD-Application) that you use in the Azure Resource Manager Endpoint.

### How can I set an AD Application as owner of an AD Application

In order to set an AD Application as an owner, you will need to get the **underlying Service Principal**. You can use the following script to get the Service Principal and to set it as owner or you can [follow this blog post](https://www.locktar.nl/programming/powershell/add-azure-ad-application-as-owner-of-another-ad-application) for more information.

```powershell
$objectIdOfApplicationToChange = "976876-6567-49e0-ab8c-e40848205883"
$objectIdOfApplicationThatNeedsToBeAdded = "98098897-86b9-4dc5-b447-c94138db3a61"

Add-AzureADApplicationOwner -ObjectId $objectIdOfApplicationToChange -RefObjectId (Get-AzureRmADApplication -ObjectId $objectIdOfApplicationThatNeedsToBeAdded | Get-AzureRmADServicePrincipal).Id
```

### How can I use Azure Pipelines and YAML for these tasks

Microsoft introduced YAML build pipelines a while ago. But there is now a **preview** for multi stage pipelines as well. See the Samples folder for a generic setup to use Azure Pipelines multi stage pipeline for build and release.
Don't forget to enable the preview feature!
