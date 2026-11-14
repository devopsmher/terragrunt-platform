# Quick start: a new team environment

Goal: a team gets an account baseline, CI roles, a VPC, a DNS zone and an EKS cluster with Karpenter from one pull request. Most of the 30 minutes is EKS creating the control plane.

## Before you start

- An AWS account for the team (from your account vending process).
- An admin session in that account for the one-time bootstrap (for example AWS SSO).
- The team's live repository with `root.hcl` from [`live/root.hcl`](../live/root.hcl).

## 1. Describe the environment

Copy [`live/payments/dev`](../live/payments/dev) to `live/<team>/<env>` and change the values:

```hcl
# env.hcl
locals {
  account_id = "222222222222"
  region     = "eu-central-1"
}
```

```hcl
# terragrunt.stack.hcl (values block)
team               = "orders"
environment        = "dev"
cidr               = "10.30.0.0/16"
zone_name          = "orders-dev.example.com"
kubernetes_version = "1.35"
github_repository  = "example-org/orders-live"
```

## 2. Bootstrap once

The CI roles are created by the `account-baseline` unit itself, so the first apply of that unit runs from a laptop with an admin session:

```bash
cd live/orders/dev
terragrunt stack generate
cd .terragrunt-stack/platform/.terragrunt-stack/account-baseline
terragrunt apply --backend-bootstrap   # creates the state bucket and the CI roles
```

## 3. Let CI take over

1. In the live repository, create the GitHub environment `orders-dev` and add required reviewers.
2. Set the repository variable `ENABLE_AWS_CI` to `true`.
3. Open a pull request with the new directory: CI plans the whole environment with the read-only role.
4. Merge it and approve the `orders-dev` deployment: CI applies the network, DNS zone and EKS cluster.

## 4. Delegate DNS

Ask the platform team to add an NS record for `orders-dev.example.com` in the parent zone, using the `name_servers` output of the `dns` unit.

## Upgrading

Change `version` in `terragrunt.stack.hcl` to the new release, open a pull request and read the plan. Upgrade `dev` first, then `prod`.
