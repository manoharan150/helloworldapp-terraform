# resource "oci_bastion_bastion" "bastion_svc" {
#   #Required
#   bastion_type     = "STANDARD"
#   compartment_id   = oci_identity_compartment.network_compartment.id
#   target_subnet_id = oci_core_subnet.vcn-bastion-private-subnet.id

#   #Optional
#   client_cidr_block_allow_list = ["0.0.0.0/0"]
#   name                         = "bastion_svc"
#   dns_proxy_status             = "ENABLED"
#   max_session_ttl_in_seconds   = 3600
# }

# resource "oci_bastion_session" "port_forwarding_session" {
#   bastion_id = oci_bastion_bastion.bastion_svc.id
#   key_details {
#     public_key_content = file(var.rsa_public_key_path)
#   }
#   target_resource_details {
#     session_type                       = "PORT_FORWARDING"
#     target_resource_id                 = oci_core_instance.bastion-compute.id
#     target_resource_private_ip_address = oci_core_instance.bastion-compute.private_ip
#     target_resource_port               = 22
#   }

#   display_name           = "bastion_session"
#   key_type               = "PUB"
#   session_ttl_in_seconds = "3600"
# }