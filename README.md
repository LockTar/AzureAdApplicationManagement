# Azure AD Application Management

Azure AD Application Management with VSTS pipeline tasks. These VSTS tasks are created with and tested on **Hosted Visual Studio 2017** agents.

This VSTS extension contains the following tasks:

- Get Azure AD Application
- New Azure AD Application
- Set Azure AD Application
- Remove Azure AD Application

In order to use these tasks, follow the **prerequisite** steps in the [Get Started](#get-started) section.

## Get Started

In order to use these tasks, a **prerequisite must be done** otherwise you will get an **unauthorized error**. Follow the steps below to fix the permission issue:

1. Create an Azure Resource Manager endpoint in your VSTS team project manually or let VSTS create one for you.
2. Go to the [Azure portal](https://portal.azure.com)
3. In the Azure portal, navigate to **App Registrations**
4. Select the created app registration. If you can't find it, you probably don't have the right permissions. You can still find the app registration by changing the filter dropdown box to **All apps**.
5. Check the **Owners** of the selected app registration (application). If your not an owner, find an **owner** or a **Global Administrator** (you will need a Global Admin in the next steps).
6. Set the **Required Permissions** at least with the following Resource Access **Windows Azure Active Directory (Microsoft.Azure.ActiveDirectory)** with the **application** permission **Manage apps that this app creates or owns**. When you save this, this will result in the following array in the **manifest**:

    ```json
    "requiredResourceAccess": [
      {
        "resourceAppId": "00000002-0000-0000-c000-000000000000",
        "resourceAccess": [
          {
            "id": "824c81eb-e3f8-4ee6-8f6d-de7f50d565b7",
            "type": "Role"
          }
        ]
      }
    ]
    ```
7. **Very important** Request an Azure Global Administrator to hit the button **Grant permissions** in the **Required Permissions** view. This only has to be done once.
8. Use any task of this extension.

## FAQ

### How can I manage an already created AD Application

Set the [owner of the AD Application to the AD Application](#How-can-I-set-an-AD-Application-as-owner-of-an-AD-Application) that you use in the Azure Resource Manager Endpoint.

### How can I set an AD Application as owner of an AD Application

In order to set an AD Application as an owner, you will need to get the **underlying Service Principal**. You can use the following script to get the Service Principal and to set it as owner or you can [follow this blog post](https://www.locktar.nl/programming/powershell/add-azure-ad-application-as-owner-of-another-ad-application) for more information.