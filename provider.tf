terraform {
  required_version = ">= 1.2.3"
  required_providers {
    oci = {
      version = "= 4.120.0"
    }
  }
}

provider "oci" {
  tenancy_ocid     = var.tenant_ocid
  user_ocid        = "ocid1.user.oc1..aaaaaaaakjtwrynw6riwuqxefgilypcmh43y4elmarrc77jqzakl26rj6w3q"
  private_key_path = "D:/DevOps/Oracle/SSH/rsa.pem"
  fingerprint      = "54:5b:6f:e5:60:e3:bd:5a:99:f7:a2:3b:d6:7b:e1:e5"
  region           = var.region
}
