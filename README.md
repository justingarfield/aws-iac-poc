# aws-iac-poc

## Prerequsites

```bash
curl --remote-name https://prerelease.keybase.io/keybase_amd64.deb
sudo apt install ./keybase_amd64.deb
run_keybase
```

## Management Root Setup

- Create new AWS Account named "Management"
- Setup MFA on Root User
  - (optional) Set Console UI to be Browser/System Theme (dark mode)
  - (optional) Set Console UI to default region for sanity sake

## Creating Bootstrap resources

- Using AWS CLI `aws login`, login as Root user
- `aws sts get-caller-identity` should now show the Root user

```bash
export AWS_REGION=us-east-1
tofu -chdir=bootstrapping-user/ init
tofu -chdir=bootstrapping-user/ validate
tofu -chdir=bootstrapping-user/ plan tfplan
tofu -chdir=bootstrapping-user/ apply tfplan -auto-approve

export GPG_TTY=$(tty)
tofu -chdir=bootstrapping-user/ output -raw iam_user_temporary_password | base64 --decode | gpg --decrypt
```

- Use the value of the `outputs.tf` from `bootstrapping-user/` to configure TOTP codes in KeePassXC, BitWarden, etc.
- Use the generated codes in this next section...

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

- `export AWS_REGION=us-east-1`
- Using AWS CLI `aws login`, login as new Bootstrapping User
  - `aws sts get-caller-identity` should now show Bootstrapping User
- `tofu -chdir=organization/ init`
- `tofu -chdir=organization/ plan -out tfplan`
- `tofu -chdir=organization/ apply tfplan -auto-approve`
- `unset AWS_REGION`

## (Clickops) Enable IAM Identity Center

- Login to the AWS Management Account Console with the Root user
- Navigate to the IAM Identity Center landing page
- Make sure you have the AWS Region you want to provision Identity Center in selected in the UI
- Click the **Enable** button
- Picked `Use AWS owned key` for now
  - (optional) May want to use a CMK here depending on compliance requirements
- Click the **Enable** button

## Control Tower

- `export AWS_REGION=us-east-1`
- Using AWS CLI `aws login`, login as new Bootstrapping User
  - `aws sts get-caller-identity` should now show Bootstrapping User
- `tofu -chdir=control-tower/ init`
- `tofu -chdir=control-tower/ plan -out tfplan`
- `tofu -chdir=control-tower/ apply tfplan -auto-approve`
- `unset AWS_REGION`
