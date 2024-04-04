# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  region = var.region
}

module "asg" {
  source="git@github.com:satishkumarkrishnan/terraform-aws-asg.git?ref=main"  
}