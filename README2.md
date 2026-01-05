# Scratchpad

## wslview configuration

```bash
sudo apt update && sudo apt install software-properties-common
sudo add-apt-repository ppa:wslutilities/wslu
sudo apt update && sudo apt install wslu
sudo sed -i 's/\/proc\/sys\/fs\/binfmt_misc\/WSLInterop/\/proc\/sys\/fs\/binfmt_misc\/WSLInterop-late/g' /usr/bin/wslview
```

## Landing Zone "Stuck" or "Broken" when initially deploying

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

# Todo: Restrict more on "arn:aws:iam::*:role/service-role/AWSControlTower*" in `AllowBootstrapperToCreateRequiredRoles` Policy

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
