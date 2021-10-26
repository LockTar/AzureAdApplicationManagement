# Azure AD Application Management

[![Build status](https://ralphjansen.visualstudio.com/AzureAdApplicationManagement/_apis/build/status/Vsts-Extension?branchName=master)](https://ralphjansen.visualstudio.com/AzureAdApplicationManagement/_build/latest?definitionId=12&branchName=master) [![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=LockTar_AzureAdApplicationManagement&metric=alert_status)](https://sonarcloud.io/dashboard?id=LockTar_AzureAdApplicationManagement)

Azure AD Application Management with Azure DevOps pipeline tasks. These Azure DevOps tasks are created with and tested on **Hosted windows-2019** agents.

This Azure DevOps extension contains the following tasks:

- Get Azure AD Application
- Set Azure AD Application (recommended)
- Update Azure AD Application
- Remove Azure AD Application

In order to use these tasks, follow the **prerequisite** steps in the [Get Started](#get-started) section.

## Get Started

In order to use these tasks, a **prerequisite must be done** otherwise you will get an **unauthorized error**. Follow the steps below to fix the permission issue:

1. Create an Azure Resource Manager endpoint in your Azure DevOps team project manually or let Azure DevOps create one for you.
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
      },
      {
        "resourceAppId": "00000003-0000-0000-c000-000000000000",
        "resourceAccess": [
          {
            "id": "7ab1d382-f21e-4acd-a863-ba3e13f7da61",
            "type": "Role"
          },
          {
            "id": "18a4783c-866b-4cc7-a460-3d5e5662c884",
            "type": "Role"
          }
        ]
      }
    ]
    ```

**NOTE** The `resourceAppId` with value `00000003-0000-0000-c000-000000000000` is optional for now but will be needed in the future by Microsoft. Is exactly the same permissions as `resourceAppId` with value `00000002-0000-0000-c000-000000000000` and id `5778995a-e1bf-45b8-affa-663a9f3f4d04` but then with the new Microsoft Graph instead of the old Azure AD graph.

7. **Very important** Request an Azure Global Administrator to hit the button **Grant admin consent for {your company}** in the **API permissions** view. This only has to be done once.
8. Use any task of this extension.

## Release notes

### V3.3

- Update Az module to version 6.5.0 (hosted agent [pull request](https://github.com/actions/virtual-environments/pull/4349) is made)
- Fix issue [#63](https://github.com/LockTar/AzureAdApplicationManagement/issues/63) of new identifier uri validation rules

### V3.2

- Delete v2 tasks from extension
- Update all NPM dependencies
- Update PowerShell Az Module to version 6.4.0 (latest and same as hosted agent)
- Update PowerShell AzureAD Module to version 2.0.2.140 (latest)
- Update readme with 'Contribute' section

### V3.1

- Mark v2 tasks as deprecated

### V3

- Migrated (were possible) to the new Az Modules
- Remove AzureRm modules everywere
- Manage AppRoles in the 'Set' task
- Manage 'User assignment required?' in the 'Set' task
- New 'Update' task that will only update the values that are given and will skip the rest
- No 'New' task for v3. Can be done with the 'Set' task (was already recommended way)
- Update documentation
- Deprecate all v2 tasks
- Don't set default Reply url when creating new application (not mandatory anymore by Microsoft)
- Don't make homepage mandatory anymore (not mandatory anymore by Microsoft)
- Change IdentifierUri to the new default format of Microsoft: api://{ApplicationId} (Argument in PowerShell is still mandatory)

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

## Contribute

### Prepare

1. Clone repository
2. Install gulp with `npm install gulp -g`
3. Navigate to folder `Vsts-Extension` in PowerShell version of your choice 5.1 (old PowerShell module is still being used)
4. Install npm packages with `npm install`
5. Install PowerShell Module `Az` (All AzureRm modules should be removed from your system as stated in the Az documentation) in PowerShell 5.1 (old PowerShell module is still being used)
6. Install PowerShell Module `AzureAD` in PowerShell 5.1 (old PowerShell module is still being used)
7. Optional: Install `Pester` for running PowerShell test scripts with `Install-Module -Name Pester -Force -SkipPublisherCheck` in PowerShell 5.1 (old PowerShell module is still being used)

### Build

1. Navigate to folder `Vsts-Extension` in PowerShell version of your choice
2. Run gulp with following commands: 
    - `gulp build` Build all tasks and set the dependencies in the tasks
    - `gulp clean` Clean all tasks
    - `gulp reset` First does a `clean` and then a `build`
    - `gulp build/clean/reset:taskname` in example `gulp build:GetAdApplication` for only building the GetAdApplication task

### Test

1. Navigate in PowerShell 5.1 (old PowerShell module is still being used) to `./scripts/ManageAadApplications/v3`
2. Login into the `Az` and `AzureAD` PowerShell module with the commands `Connect-AzAccount` and `Connect-AzureAD`. Login with a test user that doesn't have a `Global Administrator` role. If you use a Global admin, the owner won't be set and some tests will fail.
2. Run pester tests for the `ManageAadApplications` PowerShell Module. Use for this the `*.Tests.ps1` files in the `ManageAadApplications` folder. See comment at the top of the screen. In example `Invoke-Pester -Output Detailed .\Get-AadApplication.Tests.ps1`