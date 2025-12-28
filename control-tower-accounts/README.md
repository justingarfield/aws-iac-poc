# control-tower-accounts

When provisioning AWS Control Tower via APIs / IaC, you need to provide it any "Shared Accounts" _(aka "Core Accounts")_ for Log Archive, Audit, Backup Admin, and Central Backup vs. having it automatically create them for you.

It also requires that you create the `AWSControlTowerExecution` IAM Role in said accounts yourself.

We're going to take advantage of the pre-existing `OrganizationAccountAccessRole` that AWS Organizations has added to each Member account.
