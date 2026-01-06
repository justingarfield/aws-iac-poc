# aws-iac-poc

This repository contains a Proof of Concept (POC) to bootstrap a brand-new AWS Organizations + Control Tower environment. It's based on the v4.0 Landing Zone template _(latest as-of this writing)_ and follows the AWS Well-Architected / Best Practices guidance provided by AWS.

Some areas don't currently support automation and still require ClickOps, but we attempt to cut-over to Short-lived IAM Identity Center credentials and automation as soon as possible.

This is intended to _ONLY_ bootstrap an environment. This repository should always deploy on its own cadence, and be built on-top of after-the-fact. Once these resources are in-place, you should rarely _(if ever)_ have to touch this repository and its pipeline.

## Directory Layout

```sh
📂 aws-iac-poc
├─📁 .vscode                 # VS Code project-level settings and schema config
├─📁 control-tower           # OpenTofu used to provision Control Tower
└─📁 control-tower-prereqs   # OpenTofu used to provision Control Tower Prerequisites
```

## Objectives

* Deploy an AWS Control Tower enabled environment from scratch
* Use the root user for as little as possible during provisioning
* Avoid using long-lived credentials throughout the entire process
* Only deploy the bare-minimum to allow another project/pipeline to takeover from here
* Work for multiple AWS partitions _(e.g. GovCloud)_

## Prerequsites

* Ability to create a new AWS Management Account outside of any pre-existing AWS Organization
* [WSL Ubuntu 24.04](https://learn.microsoft.com/en-us/windows/wsl/install) or [equivalent](https://ubuntu.com/desktop) with `bash`
* [mise-en-place](https://mise.jdx.dev/) _(`mise trust && mise install`)_

## Concepts to Understand

### Management Account

In an AWS Organizations + Control Tower world, whichever _root account_ you decide to start with will become what's refered to as the _Management Account_. This particular AWS Account should be used as little as possible, with a majority of Administrative Tasks being delegated to AWS Organization Member Accounts.

### Shared Accounts

* Audit
* Backing Administrator
* Centralized Backup
* Log Archive accounts

## Management Root Setup _(ClickOps)_

* Create a new AWS Account named `Management`
* Setup MFA on Root User
  * _(optional)_ Set Console UI to be Browser/System Theme
  * _(optional)_ Set Console UI to Home Region for sanity sake

* Enable AWS Organizations
  * _(Note: It's easier to just manually enable this vs setting up a Bootstrapper IAM User...at this point in time there's nothing to manage anyway, as we would just end up ignoring its properties on-change)_

* Enable IAM Identity Center _(Note: IAM Identity Center cannot currently be enabled via the APIs.)_
  * Navigate to the IAM Identity Center landing page
  * Make sure you have the AWS Region you want to provision Identity Center in selected in the UI
  * Click the **Enable** button
  * Picked `Use AWS owned key` for now
    * (optional) May want to use a CMK here depending on compliance requirements
  * Click the **Enable** button

* IAM Identity Center PermissionSet
  * Create a PermissionSet named `TEMPORARY-AdministratorAccess`
  * Under _Permissions_, assign it the AWS managed policy `AdministratorAccess`
  
* IAM Identity Center User
  * Navigate to **IAM Identity Center** -> **Users**
  * Click the Add user button
  * Create new IIC user _(can use whatever for username and email, we'll nuke this User later)_
  * Select _Generate a one-time password that you can share with this user._
  * Copy the One-time password for use in future steps
  * Assign the `TEMPORARY-AdministratorAccess` PermissionSet to your new IIC User for the `Management` account
  * Naviate to the AWS Access Portal
  * Login using the newly created IIC User and One-time password
  * Configure MFA for the newly created IIC User
  * Change password

* Get temporary credentials
  * On the Access Portal page, you should now see an entry under Management for `TEMPORARY-AdministratorAccess`
  * Click on the `Access keys` link
  * Copy the CLI env var commands from **Option 1: Set AWS environment variables**

## Control Tower Prerequisites

Before you can provision Control Tower's Landing Zone programatically, you need to build-out a few prerequisite resources, which include...

* AWS Accounts: `Audit`, `Backup Administrator`, `Central Backup`, and `Log Archive`
* IAM Roles: `AWSControlTowerAdmin`, `AWSControlTowerCloudTrailRole`, `AWSControlTowerStackSetRole`, and `AWSControlTowerConfigAggregatorRoleForOrganizations`
* Organizational Units (OUs): `Sandbox` and `Security`

```bash
# Set Default AWS Region for tooling
export AWS_REGION=us-east-1

# <paste the Access Portal Access Keys CLI commands here>

# Verify you're the new IIC user
aws sts get-caller-identity

# Init / Plan / Apply OpenTofu
tofu -chdir=control-tower-prereqs/ init
tofu -chdir=control-tower-prereqs/ plan -out tfplan
tofu -chdir=control-tower-prereqs/ apply tfplan -auto-approve

# Unset Default AWS Region for tooling
unset AWS_REGION
unset AWS_SESSION_TOKEN
unset AWS_SECRET_ACCESS_KEY
unset AWS_ACCESS_KEY_ID
```

## Add `AWSControlTowerExecution` to Shared Accounts _(ClickOps)_

Since the "Switch Role" functionality of the Dashboard Account drop-down no longer exists, you'll need to configure IAM Identity Center access to the Organizational accounts.

Once you're able to use the IAM Identity Center Access Portal to get into the "shared accounts", it's time to add the required Control Tower IAM Role.

* Add the `AWSControlTowerExecution` IAM Role to Shared Accounts
* See: [Manually add the required IAM role to an existing AWS account and enroll it](https://docs.aws.amazon.com/controltower/latest/userguide/enroll-manually.html)

## Control Tower - Landing Zone

```bash
# Set Default AWS Region for tooling
export AWS_REGION=us-east-1

# Verify you're the new IIC user
aws sts get-caller-identity

# Init / Plan / Apply OpenTofu
tofu -chdir=control-tower/ init
tofu -chdir=control-tower/ plan -out tfplan
tofu -chdir=control-tower/ apply tfplan -auto-approve

# Unset Default AWS Region for tooling
unset AWS_REGION
```

## Post Control Tower Deployment

### (Clickops) Turn on "Region deny control"

* Navigate to **AWS Control Tower** -> **Landing zone settings**
* In the Details pane, click on the **Modify settings** button
* Click the **Next** button to go to the _Update governed Regions_ screen (step 2)
* Expand the _Region deny control_ section
* Select the **Enabled** option and click the **Confirm** button in the dialog that appears
* Click the **Next** button to go to the _Update service integrations_ screen (step 3)
* Click the **Next** button to go to the _Review and update landing zone_ screen (step 4)
* Click the **Update landing zone** button
* Wait for Control Tower to propogate changes

### Turn On "Automatic account enrollment"

```bash
# Might be able to use --filter or something with the AWS CLI to avoid needing `jq` here
aws controltower get-landing-zone --landing-zone-identifier <lz id> --output json | jq .[].manifest > tmp_landingzone_manifest.json

# Pass in the existing Landing Zone Manifest, but turn-on the remediation-type of INHERITANCE_DRIFT
aws controltower update-landing-zone --remediation-types INHERITANCE_DRIFT --landing-zone-identifier <lz id> --landing-zone-version 4.0 --manifest file://tmp_landingzone_manifest.json
```

## Troubleshooting

### Region Deny Control is blocking new governed region from provisioning

If you've enabled the Region Deny Control, and are getting errors when provisioning a new Region with AWS Control Tower...You should update the landing zone with the prior configuration (no new Governed region specified), and get it back to its prior state.

Next, disable Region Deny Control via the AWS Console UI.

Provision your new Governed Region.

Now re-enable Region Deny Control...with the newly Governed Region included.

### Account Factory "[/Parameters/ManagedOrganizationalUnit/AllowedValues]" error

#### Problem

When attempting to create an Account through Account Factory, after clicking the _Launch product_ button, you get the error:

`[/Parameters/ManagedOrganizationalUnit/AllowedValues] 'null' values are not allowed in templates` 

#### Cause

The Control Tower Template cannot find an Organizational Unit (OU) that's been enrolled into Control Tower, and isn't the Security OU.

#### Resolution

### Landing Zone "Stuck" or "Broken" when initially deploying

If Landing Zone gets in a "Stuck" or "Broken" state when initially deploying, you can manually call to have it decommissioned...

```bash
aws controltower delete-landing-zone --landing-zone-identifier <landing_zone_arn>
```

Note: It can take up to two hours to decommission a Landing Zone, even a brand-new one. Please be patient and don't touch things during this time. Refresh the Control Tower landing page until the warning banner goes away, or use the following AWS CLI command to monitor its status...

```bash
aws controltower get-landing-zone-operation --operation-identifier <operation_id>

# Example response:
{
    "operationDetails": {
        "operationType": "DELETE",
        "operationIdentifier": "<operation_id>",
        "status": "IN_PROGRESS",
        "startTime": "2025-12-23T14:30:53+00:00"
    }
}
```

Create a new OU, make sure it's enrolled in Control Tower, and now revisit the Launch product page.

## wslview configuration

```bash
sudo apt update && sudo apt install software-properties-common
sudo add-apt-repository ppa:wslutilities/wslu
sudo apt update && sudo apt install wslu
sudo sed -i 's/\/proc\/sys\/fs\/binfmt_misc\/WSLInterop/\/proc\/sys\/fs\/binfmt_misc\/WSLInterop-late/g' /usr/bin/wslview
```

## Assumptions squashed

* Does AWS Control Tower create the Shared Accounts (Audit, Log Archive) for me?
  * It does when using the Console to provision Control Tower
  * When using the API to provision Control Tower's landing zone, **you** _MUST_ create the Shared Accounts yourself ahead-of-time and pass them to Control Tower's Landing Zone Manifest

* Does Account Factory create the AWS Accounts themselves?
  * No, Account Factory makes calls to AWS Organizations, which then creates the Member Accounts for it. You can still create Accounts that aren't enrolled through AWS Organizations.

* Simply assume the `OrganizationAccountAccessRole` IAM Role
  * I attempted to use Assume Role with the Root User and the `OrganizationAccountAccessRole` IAM Role that AWS Organizations adds to each member account; however, Root users cannot assume roles.

## Some helpful commands

```bash
aws controltower list-landing-zones

aws controltower delete-landing-zone --landing-zone-identifier <landing zone id>

# Poll every 60-seconds to check status of Landing Zone Operation
watch -n 60 aws controltower get-landing-zone-operation --operation-identifier <operation id>
```

## References

* [](https://aws.amazon.com/blogs/security/getting-started-with-aws-sso-delegated-administration/)
* [](https://docs.aws.amazon.com/singlesignon/latest/userguide/delegated-admin.html?icmpid=docs_sso_console)
* [](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_integrate_services_list.html)
* [](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_reference_available-policies.html)
* [](https://docs.aws.amazon.com/singlesignon/latest/userguide/enable-identity-center.html)
* [](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_best-practices_member-acct.html)
* [](https://docs.aws.amazon.com//organizations/latest/userguide/orgs_integrate_services_list.html)
* [](https://docs.aws.amazon.com/organizations/latest/APIReference/action-reference.html#actions-management-account)
* [](https://docs.aws.amazon.com//organizations/latest/userguide/orgs_best-practices_mgmt-acct.html)
* [](https://docs.aws.amazon.com/controltower/latest/userguide/aws-multi-account-landing-zone.html#multi-account-guidance)
* [](https://docs.aws.amazon.com/controltower/latest/userguide/setting-up.html)
* [](https://docs.aws.amazon.com//controltower/latest/userguide/landing-zone-schemas.html)
* [Potholes for Health Checks in AWS Control Tower](https://medium.com/@eric.berberich/potholes-for-health-checks-in-aws-control-tower-1d1429a56e1a)
