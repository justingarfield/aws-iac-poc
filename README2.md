# Scratchpad

## wslview configuration

```bash
sudo apt update && sudo apt install software-properties-common
sudo add-apt-repository ppa:wslutilities/wslu
sudo apt update && sudo apt install wslu
sudo sed -i 's/\/proc\/sys\/fs\/binfmt_misc\/WSLInterop/\/proc\/sys\/fs\/binfmt_misc\/WSLInterop-late/g' /usr/bin/wslview
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
* []()
