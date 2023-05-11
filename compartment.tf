resource "oci_identity_compartment" "bastion_compartment" {
  # Required
  compartment_id = var.tenant_ocid
  description    = "Compartment for bastion relateds resources."
  name           = "bastion_compartment"
}

resource "oci_identity_compartment" "network_compartment" {
  # Required
  compartment_id = var.tenant_ocid
  description    = "Compartment for network resources."
  name           = "network_compartment"
}

resource "oci_identity_compartment" "app_compartment" {
  # Required
  compartment_id = var.tenant_ocid
  description    = "Compartment for application related resources."
  name           = "app_compartment"
}

resource "oci_identity_compartment" "monitoring_compartment" {
  # Required
  compartment_id = var.tenant_ocid
  description    = "Compartment for mointoring related resources."
  name           = "monitoring_compartment"
}