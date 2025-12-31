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
* [Keybase Client](https://keybase.io/download)
  * Also need to have a PGP Key configured to decrypt value from TF outputs
* Ability to create a new AWS Management Account outside of any pre-existing AWS Organization _(aka...have a Credit Card handy)_

## Management Root Setup

* Create new AWS Account named "Management"
* Setup MFA on Root User
  * (optional) Set Console UI to be Browser/System Theme (dark mode)
  * (optional) Set Console UI to default region for sanity sake

## Creating Bootstrap resources

* Using AWS CLI `aws login`, login as Root user
* `aws sts get-caller-identity` should now show the Root user

```bash
export AWS_REGION=us-east-1
tofu -chdir=bootstrapping-user/ init
tofu -chdir=bootstrapping-user/ validate
tofu -chdir=bootstrapping-user/ plan tfplan
tofu -chdir=bootstrapping-user/ apply tfplan -auto-approve

export GPG_TTY=$(tty)
tofu -chdir=bootstrapping-user/ output -raw iam_user_temporary_password | base64 --decode | gpg --decrypt
```

* Use the value of the `outputs.tf` from `bootstrapping-user/` to configure TOTP codes in KeePassXC, BitWarden, etc.
* Use the generated codes in this next section...

```bash
export AWS_REGION=us-east-1

MFA_SERIAL_NUMBER=$(aws iam list-virtual-mfa-devices --output json | jq -r '.VirtualMFADevices[].SerialNumber | select(contains("mfa/bootstrapper/FoundationalBootstrapper"))')
AUTH_CODE_1="479080"
AUTH_CODE_2="511887"
aws iam enable-mfa-device --user-name FoundationalBootstrapper --serial-number $MFA_SERIAL_NUMBER --authentication-code1 $AUTH_CODE_1 --authentication-code2 $AUTH_CODE_2

aws logout
unset AWS_REGION
```

## Bootstrap AWS Organizations

* `export AWS_REGION=us-east-1`
* Using AWS CLI `aws login`, login as the Bootstrapping user
  * `aws sts get-caller-identity` should now show Bootstrapping user
* `tofu -chdir=organization/ init`
* `tofu -chdir=organization/ plan -out tfplan`
* `tofu -chdir=organization/ apply tfplan -auto-approve`
* `unset AWS_REGION`

## (Clickops) Enable IAM Identity Center

* Login to the AWS Management Account Console with the Root user
* Navigate to the IAM Identity Center landing page
* Make sure you have the AWS Region you want to provision Identity Center in selected in the UI
* Click the **Enable** button
* Picked `Use AWS owned key` for now
  * (optional) May want to use a CMK here depending on compliance requirements
* Click the **Enable** button

## Control Tower OUs, Accounts and IAM Identity Center User

We create the Control Tower Accounts and OUs in preparation for Control Tower.

* `export AWS_REGION=us-east-1`
* Using AWS CLI `aws login`, login as new Bootstrapping User
  * `aws sts get-caller-identity` should now show Bootstrapping User
* `tofu -chdir=control-tower-accounts/ init`
* `tofu -chdir=control-tower-accounts/ plan -out tfplan`
* `tofu -chdir=control-tower-accounts/ apply tfplan -auto-approve`
* `unset AWS_REGION`

## (Clickops) IAM Identity Center User Setup

* Login to the AWS Management Account Console with the Root user
* Navigate to IAM Identity Center -> Users
* Open the newly created IIC User
* Click on "Reset Password"
  * Select _"Generate a one-time password and share the password with the user"_ and click *Reset password*
  * Copy the One-time password for use in the next step
* Naviate to the AWS Access Portal
* Login using the newly created IIC User and One-time password
* Configure MFA for the newly created IIC User
* Change password

Note: I attempted to use Assume Role with the Root User and the `OrganizationAccountAccessRole` IAM Role that AWS Organizations adds to each member account; however, Root users cannot assume roles.

## Add `AWSControlTowerExecution` to Shared Accounts

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
