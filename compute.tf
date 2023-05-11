resource "oci_core_instance" "bastion-compute" {
  # Required
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = oci_identity_compartment.bastion_compartment.id
  shape               = var.instance_shape

  shape_config {
    ocpus         = var.instance_ocpus
    memory_in_gbs = var.instance_shape_config_memory_in_gbs
  }

  source_details {
    source_id   = var.soruce_image_ocid
    source_type = "image"
  }

  # Optional
  display_name = "bastion-host1"
  create_vnic_details {
    assign_public_ip = true
    subnet_id        = oci_core_subnet.vcn-bastion-public-subnet.id
  }
  metadata = {
    ssh_authorized_keys = file(var.rsa_public_key_path)
  }
  preserve_boot_volume = false
}

resource "oci_core_instance" "app-compute" {
  # Required
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = oci_identity_compartment.app_compartment.id
  shape               = var.instance_shape

  shape_config {
    ocpus         = var.instance_ocpus
    memory_in_gbs = var.instance_shape_config_memory_in_gbs
  }

  source_details {
    source_id   = var.soruce_image_ocid
    source_type = "image"
  }

  # Optional
  display_name = "app-host1"
  create_vnic_details {
    assign_public_ip = false
    subnet_id        = oci_core_subnet.vcn-app-private-subnet.id
  }
  metadata = {
    ssh_authorized_keys = file(var.rsa_public_key_path)
    user_data           = base64encode(file("./userdata/app_server_init.sh"))
  }
  preserve_boot_volume = false
}

# data "template_file" "init" {
#   template = "${file("monitoring_server_init.sh")}"

#   vars = {
#     some_address = "${oci_core_instance.app-compute.private_ip}"
#   }
# }

resource "oci_core_instance" "monitoring-compute" {
  # Required
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = oci_identity_compartment.monitoring_compartment.id
  shape               = var.instance_shape

  shape_config {
    ocpus         = var.instance_ocpus
    memory_in_gbs = var.instance_shape_config_memory_in_gbs
  }

  source_details {
    source_id   = var.soruce_image_ocid
    source_type = "image"
  }

  # Optional
  display_name = "monitoring-host1"
  create_vnic_details {
    assign_public_ip = true
    subnet_id        = oci_core_subnet.vcn-monitoring-public-subnet.id
  }
  metadata = {
    ssh_authorized_keys = file(var.rsa_public_key_path)
    user_data           = base64encode(file("./userdata/monitoring_server_init.sh"))
  }
  preserve_boot_volume = false
}