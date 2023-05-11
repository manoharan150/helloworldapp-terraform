data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenant_ocid
}