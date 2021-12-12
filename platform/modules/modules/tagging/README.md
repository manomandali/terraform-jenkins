#### About this module

This module is a practical application of the BizWithAI's tagging standard, which
can be found [here](https://github.com/Nubes-Opus/bizwithai-infra/standards/tagging.md).

The standard includes more in-depth descriptions of the required tags, as well
as reasoning for their inclusion.

## Supported Terraform Versions

This Tagging Module maintains releases for terraform 1.x
You should use the 4.x version.

| Terraform Version | Module Version |
| :---------------: | :------------: |
| 1.x            | 4.x            |

## Input Variables

### Required
- `name`                - This is a human-friendly identifier for an AWS resource. When multiple versions of a
  component are deployed in the same account/region, it is RECOMMENDED to include
  some element in the name to distinguish between them. This terraform module take
  the lowercase name and changes it to the uppercase Name in the tag.
- `application-name`    - The name of the application this resource belongs to. This name
  generally maps to a deployable application artifact.
- `product`             - A product is the 'brand' or value-adding service that is marketed
  to BizWithAI customers. It is a logical representation of how the business or
  customer identifies and uses our services. A product can consist of several
  application deployments.
- `environment`         - A collection of values used to define the type and style of
  resources provisioned to host an application. The environment also defines the
  SLA and governance standards that apply to those resources. The values for these
  tags are enumerated below.
  **acceptable values** : ["demo", "dev", "qa", "uat", "prod"]

- `aws-account-type`	- Categorizes the AWS Account Type as a Tag. Will be auto-populated. **acceptable values** : ["prod","non-prod"]
- `team`                - Identifies the team that is responsible for the application.
- `contact`             - A personal email or email distribution group to contact with questions
  pertaining to the SLA, cost, or existence of the resources. The value consists
  of a common name and email address seperated by a colon.
- `ci-owner` - The Configuration Item (CI) owner of the infrastructure item. This should be the user id of that owner.
  **acceptable values** : ["raja","manohar"]


- `business-unit` - AWS billable assets designated for use by BizWithAI be tagged accordingly, so that their respective total
  costs/usage can be easily tracked.
  **acceptable values** : ["nubesopus","clients"]


- `repository`          - The URL of the repository where this infrastructure is described
  in code (or at least documented). The expectation is that this is a cloneable link.
  For Git repositories use the https version of the repo and leave off the .git from the URL,
  as most modern Git repository hosts and latest versions of git [will work without this extension](https://git-scm.com/book/en/v2/Git-on-the-Server-The-Protocols)
  The maximum value length is 256 Unicode characters.
- `enable-backup`       - Represents the time window that the backup should be taken. MUST be one of the values listed.
  **acceptable values** : ["4am-6am-utc","7am-9am-utc"]
- `offhours`	        - Representation of whether the infrastructure should
  remain running at all times.
  A schedule of on/off hours can be configured, example below.
```* Examples:
* on  [implies night and weekend offhours using the default time zone configured in the policy (tz=est if unspecified) and the default onhour and offhour values configured in the policy.]
* off [this disables off hours]
* off=(M-F,19);on=(M-F,7)
* off=[(M-F,21),(U,18)];on=[(M-F,6),(U,10)];tz=pt
```

### Required - if using this module
- `tf-state-bucket`     - The name of the S3 bucket containing the resource's
  terraform state.
- `tf-state-key`        - The name of the S3 bucket key containing the resource's
  terraform state.
- ~~`tf-workspace`        - The name of the terraform workspace.~~ This is inferred by your projects workspace.

### Optional
- `cost-center`    - The financial bucket that will be charged for this aws
  entity.
- `issue-tracking` - An associated JIRA ticket tracking any issues.
- `dtmonitor` - A collection of values to determine the level of monitoring. There are three possible outcomes; no monitoring, infrastructure monitoring, and full monitoring. The values for these tags are enumerated below.
  **acceptable values** : ["false","infra","full"]


### Additionally provided for you
- `infrastructure-management` - The technology used to launch and manage the
  resource. (i.e. "terraform")
- `tagging-module-version`    - The version of the this module. (default:"${local.tagging-module-version}")
  [tagging module used.](https://github.com/Nubes-Opus/bizwithai-infra/platform/modules/tagging)

Outputs
------
- `tags`                              - A map variable containing derived tags.
  **Includes the optional tags
  `business-unit`, `cost-center`,
  `enable-backup`, `issue-tracking`,
  `repository`, if a value is passed
  in.**
- `autoscaling_tags`                  - A map variable containing derived
  objects that include tags and a
  `propagate_at_launch` attribute. For use
  in Autoscaling Groups.  **Includes the
  optional tags `business-unit`,
  `cost-center`, `enable-backup`,
  `issue-tracking`, `repository`,
  if a value is passed in.**


Usage
-----
You can use these in your terraform template with the following steps.

1.) Adding a module resource to your template (e.g. `main.tf`) and using it
to create a merged tag map.

**Note:** when the module's output is used, the tag `Name` will act the same as
all the other tags. This can lead to multiple resources created with the same
name. If this will cause issues with your template, or if you'd just like to
have the names be different, the example below shows how to overwrite one of
the tags in the module for a given resource.

2.) Notice that there is a mix of empty strings and nulls below, neither result
in a tag being created.

## main.tf
```
module "tags" {
  source           = "git::https://github.com/Nubes-Opus/bizwithai-infra/platform/modules/tagging?ref=v3.0.1"
  name             = "${var.name}"//*(footnote 1)
  application-name = "${var.application-name}"
  product          = "${var.product}"
  environment      = "${var.environment}"
  contact          = "${var.contact}"
  tf-state-bucket  = "${var.tf-state-bucket}"
  tf-state-key     = "${var.tf-state-key}"

  aws-account-type = "${var.aws-account-type}"
  team             = "${var.team}"
  ci-owner         = "${var.ci-owner}"
  business-unit    = "${var.business-unit}"
  repository       = "https://github.com/Nubes-Opus/bizwithai-infra/platform/modules/tagging"
  enable-backup    = "${var.enable-backup}"
  offhours         = "${var.offhours}"
  issue-tracking   = ""
  dtmonitor        = "${var.monitoring}"
}

resource "aws_instance" "foo" {
tags = "${merge(module.tagging.tags,
                  map("non-required-tag", "Howdy"))}"


```

2.) Setting values for the following variables, either through
`terraform.tfvars` or `-var` arguments on the CLI. It's a good idea to have
most of these externalized into a variable for use elsewhere in the template,
- issue-tracking
- business-unit

*(1)Looking at the tagging standards, "Name" is the standard. This is because
Name is used by amazon to fill the name column on the console. It was determined
though that, the tagging module would except "name" and convert it on the
backend to "Name" to account for Amazon's capitalization preference. So if you
are going to overwrite this after the tagging module does it's work for you then
you need to overwrite it with "Name".

## Updating the Module

Make your changes off master, change the local.tf to your new version, merge to master and add a `tag` from the
`commit` with the version you just added (v4.#.#)