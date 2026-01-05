# aws-iac-poc

This repository contains a Proof of Concept (POC) 

## Objectives

* Deploy an AWS Control Tower enabled environment from scratch
* Use the root user for as little as possible during provisioning
* Provision as much as possible using OpenTofu
* Avoid using long-lived credentials throughout the entire process

## Prerequsites

* [WSL Ubuntu 24.04](https://learn.microsoft.com/en-us/windows/wsl/install) or [equivalent](https://ubuntu.com/desktop)
* [mise-en-place](https://mise.jdx.dev/)
* Ability to create a new AWS Management Account outside of any pre-existing AWS Organization _(aka...have a Credit Card handy)_

## Concepts to Understand

* Management Account
  * In an AWS Organizations + Control Tower world, whichever "root account" you decide to "start with" will become what's refered to as the "Management Account". This particular AWS Account should be used as little as possible, with a majority of Administrative Tasks delegated to AWS Organization Member Accounts.
* Shared Accounts
  * Audit
  * Backing Administrator
  * Centralized Backup
  * Log Archive accounts

## (Clickops) Management Root Setup

* Create new AWS Account named "Management"
* Setup MFA on Root User
  * (optional) Set Console UI to be Browser/System Theme (dark mode)
  * (optional) Set Console UI to default region for sanity sake
* Enable AWS Organizations _(Note: It's easier to just manually enable this vs setting up a Bootstrapper IAM User...at this point in time there's nothing to manage anyway, as we would just end up ignoring its properties on-change)_
  * 
* Enable IAM Identity Center _(Note: IAM Identity Center cannot currently be enabled via the APIs.)_
  * Navigate to the IAM Identity Center landing page
  * Make sure you have the AWS Region you want to provision Identity Center in selected in the UI
  * Click the **Enable** button
  * Picked `Use AWS owned key` for now
    * (optional) May want to use a CMK here depending on compliance requirements
  * Click the **Enable** button
* IAM Identity Center User Setup
  * Login to the AWS Management Account Console with the Root user
  * Navigate to IAM Identity Center -> Users
  * Create a temporary PermissionSet to assign the `AdministratorAccess` IAM Role for the Management Account to your newly created IIC User
  * Open the newly created IIC User
  * Click on "Reset Password"
    * Select _"Generate a one-time password and share the password with the user"_ and click *Reset password*
    * Copy the One-time password for use in the next step
  * Naviate to the AWS Access Portal
  * Login using the newly created IIC User and One-time password
  * Configure MFA for the newly created IIC User
  * Change password

## Control Tower OUs, Accounts and IAM Identity Center User

We create the Control Tower Accounts and OUs in preparation for Control Tower.

* `export AWS_REGION=us-east-1`
* Using AWS CLI `aws sso login`, login as new IIC User
  * `aws sts get-caller-identity` should now show IIC User
* `tofu -chdir=control-tower-accounts/ init`
* `tofu -chdir=control-tower-accounts/ plan -out tfplan`
* `tofu -chdir=control-tower-accounts/ apply tfplan -auto-approve`
* `unset AWS_REGION`

## (Clickops) Add `AWSControlTowerExecution` to Shared Accounts

Since the "Switch Role" functionality of the Dashboard Account drop-down no longer exists, you'll need to configure IAM Identity Center access to the Organizational accounts.

Once you're able to use the IAM Identity Center Access Portal to get into the "shared accounts", it's time to add the required Control Tower IAM Role.

* Add the `AWSControlTowerExecution` IAM Role to Shared Accounts
* See: [Manually add the required IAM role to an existing AWS account and enroll it](https://docs.aws.amazon.com/controltower/latest/userguide/enroll-manually.html)

## Control Tower - Landing Zone

* `export AWS_REGION=us-east-1`
* Using AWS CLI `aws login`, login as new Bootstrapping User
  * `aws sts get-caller-identity` should now show Bootstrapping User
* `tofu -chdir=control-tower/ init`
* `tofu -chdir=control-tower/ plan -out tfplan`
* `tofu -chdir=control-tower/ apply tfplan -auto-approve`
* `unset AWS_REGION`

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
aws controltower get-landing-zone --landing-zone-identifier 143EDCTTOGQDMP5V --output json | jq .[].manifest > tmp_landingzone_manifest.json

# Pass in the existing Landing Zone Manifest, but turn-on the remediation-type of INHERITANCE_DRIFT
aws controltower update-landing-zone --remediation-types INHERITANCE_DRIFT --landing-zone-identifier 143EDCTTOGQDMP5V --landing-zone-version 4.0 --manifest file://tmp_landingzone_manifest.json
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

Create a new OU, make sure it's enrolled in Control Tower, and now revisit the Launch product page.
